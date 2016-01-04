# Assumes Ubuntu 14.04

.PHONY: install develop ci-dependencies socat test

install:
	cp bin/dokku-daemon /usr/local/bin/dokku-daemon
	cp init/dokku-daemon.conf /etc/init/dokku-daemon.conf
	$(MAKE) socat

develop:
	rm -f /usr/local/bin/dokku-daemon /etc/init/dokku-daemon.conf
	ln -s $(PWD)/bin/dokku-daemon /usr/local/bin/dokku-daemon
	ln -s $(PWD)/init/dokku-daemon.conf /etc/init/dokku-daemon.conf
	$(MAKE) socat

ci-dependencies: shellcheck bats

shellcheck:
ifeq ($(shell shellcheck > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
	brew install shellcheck
else
	sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse'
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
	sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse'
	sudo apt-get update -qq && sudo apt-get install -qq -y socat
endif
endif

test:
	@bats tests
	@shellcheck bin/dokku-daemon
