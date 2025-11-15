#!/usr/bin/env bash

log_info() {
  gum log --level info "$*"
}

log_success() {
  gum log --level info --prefix "✓" "$*"
}

log_error() {
  gum log --level error "$*" >&2
}

log_warn() {
  gum log --level warn "$*"
}

log_step() {
  gum style --foreground 212 "==> $*"
  echo
}

log_header() {
  echo
  gum style \
    --border double \
    --align center \
    --width 50 \
    --margin "1 2" \
    --padding "1 4" \
    "$*"
  echo
}

confirm() {
  gum confirm "$*"
}

read_input() {
  local prompt="$1"
  local default="$2"
  gum input --placeholder "$default" --prompt "$prompt: "
}
