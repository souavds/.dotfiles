#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Installing Packages"

log_info "Installing packages from list..."

while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  
  paru -S --needed --noconfirm "$pkg" || log_warn "Failed to install: $pkg"
done < "$SCRIPT_DIR/../packages/arch/packages"

log_success "Package installation complete"
