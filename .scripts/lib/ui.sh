#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

confirm() {
  local prompt="$1"
  local default="${2:-false}"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY-RUN] Would prompt: $prompt"
    return 0
  fi

  if [[ "$default" == "true" ]]; then
    read -p "$prompt (Y/n) " -n 1 -r
    echo
    [[ -z "$REPLY" ]] || [[ $REPLY =~ ^[Yy]$ ]]
  else
    read -p "$prompt (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
  fi
}

header() {
  echo ""
  echo "========================================"
  echo "  $*"
  echo "========================================"
  echo ""
}
