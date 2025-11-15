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
    
    if [[ "$package_type" == "AUR" ]]; then
      paru -S --needed --noconfirm "$pkg" || log_warn "Failed to install: $pkg"
    else
      sudo pacman -S --needed --noconfirm "$pkg" || log_warn "Failed to install: $pkg"
    fi
  done < "$list_file"
}

# Install shell tools
install_from_list "$SCRIPT_DIR/../packages/arch/shell.txt" "shell"

# Install dev tools
if confirm "Install development tools?"; then
  install_from_list "$SCRIPT_DIR/../packages/arch/dev.txt" "dev"
fi

# Install terminal emulators
if confirm "Install terminal emulators (ghostty, kitty)?"; then
  install_from_list "$SCRIPT_DIR/../packages/arch/terminals.txt" "terminals"
fi

# Install fonts
if confirm "Install fonts?"; then
  install_from_list "$SCRIPT_DIR/../packages/arch/fonts.txt" "fonts"
fi

# Install system utilities
install_from_list "$SCRIPT_DIR/../packages/arch/system.txt" "system"

# Install AUR packages
if confirm "Install AUR packages (1password, spotify, etc.)?"; then
  install_from_list "$SCRIPT_DIR/../packages/arch/aur.txt" "AUR"
fi

log_success "Package installation complete"
