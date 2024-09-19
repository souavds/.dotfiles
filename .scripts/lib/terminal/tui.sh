#!/usr/bin/env sh

function log() {
  gum log -sl info "$*"
}

function confirm() {
  gum confirm "$*"
}

function choose() {
  gum choose --no-limit --header "$*" 
}
