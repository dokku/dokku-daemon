# test functions
assert_success() {
  [[ "$status" -eq 0 ]]
}

assert_failure() {
  [[ "$status" -ne 0 ]]
}

assert_output() {
  [[ "$output" = "$1" ]]
}

assert_output_contains() {
  echo "$output" | grep "$1"
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
  echo "$1" | sudo nc -U "/tmp/dokku-daemon.sock" -q 2
}
