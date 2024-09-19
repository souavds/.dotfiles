#!/usr/bin/env sh

function cleanup() {
  log ">>> Clean up"

  rm -rf ./tmp
  $@ gum

  echo "<<< Clean up"
}
