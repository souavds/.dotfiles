#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Installing Packages"

log_info "Installing packages from list..."

while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  brew install "$pkg" || log_warn "Failed to install: $pkg"
done < "$SCRIPT_DIR/../packages/darwin/packages"

log_success "Package installation complete"
