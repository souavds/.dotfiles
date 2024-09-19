#!/usr/bin/env sh

function languages() {
  log ">>> Languages"

  check_and_install mise

  mise use -g node go
  KERL_CONFIGURE_OPTIONS="--enable-wx" mise use -g erlang
  mise use -g elixir
  mise reshim

  log "<<< Languages"
}

function shell_setup() {
  log ">>> Shell setup"

  mise use -g usage

  log "<<< Shell setup"
}
