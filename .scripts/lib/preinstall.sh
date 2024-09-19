#!/usr/bin/env sh

function preinstall() {
  echo ">>> Script dependencies"

  $@ gum

  echo "<<< Script dependencies"
}
