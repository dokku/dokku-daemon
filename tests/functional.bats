#!/usr/bin/env bats

load test_helper

@test "(cli) invoking with -h displays usage" {
  run dokku-daemon -h

  assert_success
  assert_output_contains "Usage:"
}

@test "(cli) invoking with -v displays version number" {
  run dokku-daemon -v

  assert_success
  assert_output_contains "[0-9]\.[0-9]\.[0-9]"
}

@test "(cli) invoking with unknown option results in failure" {
  run dokku-daemon --batman

  assert_failure
  assert_output_contains "Error:"
}

@test "(env) DOKKU_SOCK_PATH controls location of daemon's socket" {
  daemon_start DOKKU_SOCK_PATH="$BATS_TMPDIR/dokku-custom.sock"

  [ -e "$BATS_TMPDIR/dokku-custom.sock" ]

  daemon_stop
}

@test "(env) DOKKU_LOGS_DIR controls location of daemon's logs" {
  daemon_start DOKKU_LOGS_DIR="$BATS_TMPDIR"

  [ -e "$BATS_TMPDIR/dokku-daemon.log" ]

  daemon_stop
}

@test "(cmd) invalid dokku commands receive standard response" {
  daemon_start

  run client_command "app"
  assert_output_contains '"ok":false'
  assert_output_contains '"output":"Invalid command"'

  run client_command "foobar"
  assert_output_contains '"ok":false'
  assert_output_contains '"output":"Invalid command"'

  daemon_stop
}

@test "(cmd) commands that prompt the user are handled correctly" {
  daemon_start

  run client_command "shell"
  assert_output_contains '"ok":false'
  assert_output_contains '"output":"Not implemented"'

  run create_app "destroy-me"
  run client_command "apps:destroy destroy-me"
  assert_output_contains "Destroying destroy-me"
  run destroy_app "destroy-me"

  daemon_stop
}

@test "(cmd) responses are encoded as a single line" {
  daemon_start

  run create_app demo-app-one
  run create_app demo-app-two

  run client_command "apps"
  assert_output_contains "\\n"
  [ "${#lines[@]}" -eq 1 ]

  run destroy_app demo-app-one
  run destroy_app demo-app-two

  daemon_stop
}

@test "(cmd) commands and responses are logged" {
  daemon_start DOKKU_LOGS_DIR="$BATS_TMPDIR"

  run client_command "apps:create demo-app-log"
  response="$output"

  run cat "$BATS_TMPDIR/dokku-daemon.log"
  assert_output_contains "apps:create demo-app-log"
  assert_output_contains "$response"

  run destroy_app "demo-app-log"

  daemon_stop
}
