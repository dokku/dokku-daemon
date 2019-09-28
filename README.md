# dokku-daemon [![Travis branch](https://img.shields.io/travis/dokku/dokku-daemon/master.svg?style=flat-square)](https://travis-ci.org/dokku/dokku-daemon)

A daemon wrapper around [Dokku](https://github.com/dokku/dokku)

## Requirements

A VM running Ubuntu 14.04 x64 or later with Dokku v0.4.9 or above installed

## Installing

As a user with access to `sudo`:

    git clone https://github.com/dokku/dokku-daemon
    cd dokku-daemon
    sudo make install

## Debian Notes

As a user with access to `sudo`:

    git clone https://github.com/dokku/dokku-daemon
    cd dokku-daemon
    sudo apt-get install socat
    sudo make install

## Specifications

* Daemon listens on a UNIX domain socket (by default created at `/var/run/dokku-daemon/dokku-daemon.sock`)
* Commands issued to the daemon take the same form as those used with `dokku` on the command-line
* Command names are validated before execution
* Responses are sent as line-delimited JSON
* No authentication layer (local/container connections only)
* Multiple client connections are supported but only one command will be processed at a given time

Example command and response:

    < apps:create demo-app
    > {"ok":true,"output":"Creating demo-app... done"}

## Development

A development environment can be started with the provided Vagrantfile. To start the box and run the test suite:

    # on development machine
    vagrant up
    vagrant ssh

    # over vagrant ssh session
    cd /dokku-daemon
    make test

The executable and init scripts are symlinked to their respective directories rather than copied. To test using Systemd, start Vagrant with environment variable `BOX_NAME` set to `bento/ubuntu-15.04`.

## License

[MIT License](LICENSE.txt)
