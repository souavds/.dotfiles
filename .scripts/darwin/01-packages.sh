#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Installing Packages"

# Read all packages into array (skip comments and empty lines)
packages=()
while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  packages+=("$pkg")
done < "$SCRIPT_DIR/../packages/darwin/packages"

if [[ ${#packages[@]} -eq 0 ]]; then
  log_warn "No packages found in list"
  exit 0
fi

log_info "Found ${#packages[@]} packages to install"

# Install all packages at once
gum spin --spinner dot --title "Installing packages..." -- \
  brew install "${packages[@]}"

log_success "Package installation complete (${#packages[@]} packages)"
