#!/usr/bin/env bats

load test_helper

@test "(cli) invoking with -h displays usage" {
  run dokku-daemon -h

  assert_success
  assert_contains "${lines[*]}" "Usage:"
}

@test "(cli) invoking with -v displays version number" {
  run dokku-daemon -v

  assert_success
  assert_contains "${lines[*]}" "Version"
}

@test "(cli) invoking with unknown option results in failure" {
  run dokku-daemon --batman

  assert_exit_status 1
  assert_contains "${lines[*]}" "Error:"
}

@test "(env) DOKKU_SOCK_PATH controls location of daemon's socket" {
  daemon_start DOKKU_SOCK_PATH="$BATS_TMPDIR/dokku-custom.sock"

  assert_exists "$BATS_TMPDIR/dokku-custom.sock"

  daemon_stop
}

@test "(env) DOKKU_DAEMON_LOGFILE controls location of daemon's logs" {
  daemon_start DOKKU_DAEMON_LOGFILE="$BATS_TMPDIR/dokku-daemon.log"

  assert_exists "$BATS_TMPDIR/dokku-daemon.log"

  daemon_stop
}

@test "(cmd) invalid dokku commands receive standard response" {
  daemon_start

  run client_command "batman"
  assert_contains "${lines[*]}" '"ok":false'
  assert_contains "${lines[*]}" '"output":"Invalid command"'

  run client_command "foobar"
  assert_contains "${lines[*]}" '"ok":false'
  assert_contains "${lines[*]}" '"output":"Invalid command"'

  daemon_stop
}

@test "(cmd) *:help dokku commands are allowed through" {
  daemon_start

  run client_command "apps:help"
  assert_contains "${lines[*]}" '"ok":true'
  assert_contains "${lines[*]}" 'apps:create <app>'

  daemon_stop
}

@test "(cmd) non-existant *:help dokku commands fail" {
  daemon_start

  run client_command "apps:create:help"
  assert_contains "${lines[*]}" '"ok":false'
  assert_contains "${lines[*]}" 'is not a dokku command'

  daemon_stop
}

@test "(cmd) commands that prompt the user are handled correctly" {
  daemon_start

  run client_command "shell"
  assert_contains "${lines[*]}" '"ok":false'
  assert_contains "${lines[*]}" '"output":"Not implemented"'

  run create_app "destroy-me"
  run client_command "apps:destroy destroy-me"
  assert_contains "${lines[*]}" '"ok":false'
  assert_contains "${lines[*]}" "Requires --force flag"
  run destroy_app "destroy-me"

  run create_app "destroy-me-force"
  run client_command "--force apps:destroy destroy-me-force"
  assert_contains "${lines[*]}" '"ok":true'
  assert_contains "${lines[*]}" "Destroying destroy-me-force"
  run destroy_app "destroy-me-force"
}

@test "(cmd) commands with app flag that prompt the user are handled correctly" {
  if dokku version | grep '^0.4.'; then
    skip "--app flag not available below 0.5.x"
  fi
  daemon_start

  run create_app "destroy-me-app-flag"
  run client_command "--app destroy-me-app-flag apps:destroy"
  assert_contains "${lines[*]}" '"ok":false'
  assert_contains "${lines[*]}" "Requires --force flag"
  run destroy_app "destroy-me-app-flag"

  run create_app "destroy-me-force-app-flag"
  run client_command "--app destroy-me-force-app-flag --force apps:destroy"
  assert_contains "${lines[*]}" '"ok":true'
  assert_contains "${lines[*]}" "Destroying destroy-me-force-app-flag"
  run destroy_app "destroy-me-force-app-flag"

  daemon_stop
}

@test "(cmd) responses are encoded as a single line" {
  daemon_start

  run create_app demo-app-one
  run create_app demo-app-two

  run client_command "apps:list"
  assert_contains "${lines[*]}" "\\n"
  [ "${#lines[@]}" -eq 1 ]

  run destroy_app demo-app-one
  run destroy_app demo-app-two

  daemon_stop
}

@test "(cmd) commands and responses are logged" {
  daemon_start DOKKU_DAEMON_LOGFILE="$BATS_TMPDIR/dokku-daemon.log"

  run client_command "apps:create demo-app-log"
  response="$output"

  run cat "$BATS_TMPDIR/dokku-daemon.log"
  assert_contains "${lines[*]}" "apps:create demo-app-log"
  assert_contains "${lines[*]}" "$response"

  run destroy_app "demo-app-log"

  daemon_stop
}
