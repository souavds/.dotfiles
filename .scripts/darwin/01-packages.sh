#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_step "Installing packages"

# Function to install from package list
install_from_list() {
  local list_file="$1"
  local package_type="$2"
  
  if [[ ! -f "$list_file" ]]; then
    log_warn "Package list not found: $list_file"
    return
  fi
  
  log_info "Installing $package_type packages..."
  
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    brew install "$pkg" || log_warn "Failed to install: $pkg"
  done < "$list_file"
}

# Install shell tools
install_from_list "$SCRIPT_DIR/../packages/darwin/shell.txt" "shell"

# Install dev tools
if confirm "Install development tools?"; then
  install_from_list "$SCRIPT_DIR/../packages/darwin/dev.txt" "dev"
fi

log_success "Package installation complete"
