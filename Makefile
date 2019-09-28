# Assumes Ubuntu >= 14.04

.PHONY: install develop ci-dependencies socat test

install:
	rm -f /usr/bin/dokku-daemon /etc/init/dokku-daemon.conf /etc/systemd/system/dokku-daemon.service
	cp -f bin/dokku-daemon /usr/bin/dokku-daemon
ifeq ($(shell /sbin/init --version 2>&1 | grep -q upstart; echo $$?), 0)
	cp -f init/dokku-daemon.conf /etc/init/dokku-daemon.conf
	initctl reload-configuration
endif
ifeq ($(shell systemctl 2>&1 | grep -q "\-\.mount"; echo $$?), 0)
	cp -f init/dokku-daemon.service /etc/systemd/system/dokku-daemon.service
	systemctl daemon-reload
endif
	$(MAKE) socat

develop:
	rm -f /usr/bin/dokku-daemon /etc/init/dokku-daemon.conf /etc/systemd/system/dokku-daemon.service
	ln -s $(CURDIR)/bin/dokku-daemon /usr/bin/dokku-daemon
ifeq ($(shell /sbin/init --version 2>&1 | grep -q upstart; echo $$?), 0)
	ln -s $(CURDIR)/init/dokku-daemon.conf /etc/init/dokku-daemon.conf
	initctl reload-configuration
endif
ifeq ($(shell systemctl 2>&1 | grep -q "\-\.mount"; echo $$?), 0)
	ln -s $(CURDIR)/init/dokku-daemon.service /etc/systemd/system/dokku-daemon.service
	systemctl daemon-reload
endif
	$(MAKE) socat

ci-dependencies: shellcheck bats

shellcheck:
ifeq ($(shell shellcheck > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
	brew install shellcheck
else
	sudo add-apt-repository universe
	sudo apt-get update -qq && sudo apt-get install -qq -y shellcheck
endif
endif

bats:
ifeq ($(shell bats > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
	git clone https://github.com/sstephenson/bats.git /tmp/bats
	cd /tmp/bats && sudo ./install.sh /usr/local
	rm -rf /tmp/bats
else
	sudo add-apt-repository ppa:duggan/bats --yes
	sudo apt-get update -qq && sudo apt-get install -qq -y bats
endif
endif

socat:
ifeq ($(shell socat > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
	brew install socat
else
	sudo add-apt-repository universe
	sudo apt-get update -qq && sudo apt-get install -qq -y socat
endif
endif

setup-travis:
	wget -nv -O - https://packagecloud.io/gpg.key | apt-key add -
	echo "deb https://packagecloud.io/dokku/dokku/ubuntu/ bionic main" | tee /etc/apt/sources.list.d/dokku.list
	apt-get update
	apt-get install -o Dpkg::Options::="--force-confold" --force-yes -y docker-engine
ifeq ($(DOKKU_VERSION),master)
	apt-get -y --no-install-recommends install "dokku"
else
	apt-get -y --no-install-recommends install "dokku=$(DOKKU_VERSION)"
endif

test:
	@bats tests
	@shellcheck bin/dokku-daemon
