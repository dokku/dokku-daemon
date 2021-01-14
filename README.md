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

## Usage

Start the service:

    systemctl start dokku-daemon

Use `socat` to connect to the socket:

    socat - UNIX-CONNECT:/var/run/dokku-daemon/dokku-daemon.sock

Example command and response:

    < apps:create python-app
    > {"ok":true,"output":"Creating python-app... done"}

### Usage within a Dokku app

To use this within a Dokku app named `python-app`, you would need to mount the socket:

```shell
dokku storage:mount python-app-app /var/run/dokku-daemon/dokku-daemon.sock:/var/run/dokku-daemon/dokku-daemon.sock
```

At this point, a command can be written to the mounted socket within your application. The following is some sample python code that would create an app named `example-app`:

```python
import os
import subprocess

def run_command(command, timeout=60):
    daemon_socket = '/var/run/dokku-daemon/dokku-daemon.sock'
    if not os.path.exists(daemon_socket) or not os.access(daemon_socket, os.W_OK):
        return False

    subprocess_command = [
        'nc',
        '-q', '2',            # time to wait after eof
        '-w', '2',            # timeout
        '-U', daemon_socket,  # socket to talk to
    ]

    ps = subprocess.Popen(['echo', command], stdout=subprocess.PIPE)
    output = None

    with subprocess.Popen(
            subprocess_command,
            stdin=ps.stdout,
            stdout=subprocess.PIPE,
            preexec_fn=os.setsid) as process:
        try:
            output = process.communicate(timeout=timeout)[0]
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGINT)  # send signal to the process group
            output = process.communicate()[0]
    ps.wait(timeout)

    return ps.returncode == 0

run_command("apps:create example-app")
```

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
