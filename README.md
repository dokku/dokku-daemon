# dokku-daemon

A daemon wrapper around [Dokku](https://github.com/dokku/dokku)

## Requirements
A VM running Ubuntu 14.04 x64 with Dokku v0.4.6 installed

## Installing
Clone this repository, and as a user with access to `sudo`:

    cd /path/to/dokku-daemon
    sudo make install

## Protocol
The daemon listens on a UNIX domain socket (by default created at `/tmp/dokku-daemon.sock`) and responds to commands with line-delimited JSON. Clients are served in order of connection.

    < apps:create demo-app
    > {"ok":true,"output":"Creating demo-app... done"}

Note that commands are identical in form to those issued to the `dokku` command-line interface.

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
MIT License - See `LICENSE.txt`
