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
  sudo start dokku-daemon "$@"  &> /dev/null || sudo restart dokku-daemon "$@" &> /dev/null
}

daemon_stop() {
  sudo stop dokku-daemon &> /dev/null
}

client_command() {
  echo "$1" | sudo nc -U "/var/run/dokku-daemon/dokku-daemon.sock" -q 2
}
