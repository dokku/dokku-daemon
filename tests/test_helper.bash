# test functions
flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$*"
    fi
  }
  return 1
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_exit_status() {
  assert_equal "$status" "$1"
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_exists() {
  if [ ! -e "$1" ]; then
    flunk "expected file to exist: $1"
  fi
}

assert_contains() {
  if [[ "$1" != *"$2"* ]]; then
    flunk "expected $2 to be in: $1"
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

# dokku functions
create_app() {
  dokku apps:create "$1"
}

destroy_app() {
  echo "$1" | dokku apps:destroy "$1"
}

# dokku-daemon functions
daemon_start() {
  if [[ `/sbin/init --version 2>&1` =~ upstart ]]; then
    sudo start dokku-daemon "$@"  &> /dev/null || sudo restart dokku-daemon "$@" &> /dev/null
  fi

  if [[ `systemctl 2>&1` =~ -\.mount ]]; then
    if [[ "$#" -gt 0 ]]; then
      echo "$@" | sudo tee /etc/systemd/system/dokku-daemon.env
      sudo systemctl daemon-reload
    fi

    sudo systemctl restart dokku-daemon.service
  fi

  # Wait 1 second for daemon to start
  sleep 1s
}

daemon_stop() {
  if [[ `/sbin/init --version 2>&1` =~ upstart ]]; then
    sudo stop dokku-daemon &> /dev/null
  fi

  if [[ `systemctl 2>&1` =~ -\.mount ]]; then
    sudo systemctl stop dokku-daemon.service
    sudo rm -f /etc/systemd/system/dokku-daemon.env
  fi
}

client_command() {
  echo "$1" | sudo nc -U "/var/run/dokku-daemon/dokku-daemon.sock" -q 2
}
