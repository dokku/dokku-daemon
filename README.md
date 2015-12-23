# dokku-daemon

A daemon wrapper around [Dokku](https://github.com/dokku/dokku)

## Requirements
A VM running Ubuntu 14.04 x64 with Dokku v0.4.6 installed

## Installing
Clone this repository, and as a user with access to `sudo`:

    cd /path/to/dokku-daemon
    sudo make install

## Specifications
* Daemon listens on a UNIX domain socket (by default created at `/tmp/dokku-daemon.sock`)
* Commands issued to the daemon take the same form as those used with `dokku` on the cli
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
    cd /path/to/dokku-daemon
    vagrant up
    vagrant ssh
    
    # over vagrant ssh session
    cd /dokku-daemon
    make test

The executable and Upstart init are symlinked to their respective directories rather than copied.

## License
[MIT License](LICENSE.txt)