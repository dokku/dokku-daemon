# Assumes Ubuntu 14.04

.PHONY: install install-development test test-deps

install:
	cp bin/dokku-daemon /usr/local/bin/dokku-daemon
	cp init/dokku-daemon.conf /etc/init/dokku-daemon.conf

install-development:
	ln -s $(PWD)/bin/dokku-daemon /usr/local/bin/dokku-daemon
	ln -s $(PWD)/init/dokku-daemon.conf /etc/init/dokku-daemon.conf
	sleep 5 && initctl reload-configuration

test:
	@bats tests || true

test-deps:
ifneq ($(shell bats --version > /dev/null 2>&1 ; echo $$?),0)
	git clone https://github.com/sstephenson/bats.git /tmp/bats
	cd /tmp/bats && sudo ./install.sh /usr/local
	rm -rf /tmp/bats
endif
