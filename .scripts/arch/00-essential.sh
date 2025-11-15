#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_step "Installing essential packages"

# Update system
log_info "Updating package database..."
sudo pacman -Sy --noconfirm

# Install essential packages
log_info "Installing essential packages..."
while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  sudo pacman -S --needed --noconfirm "$pkg"
done < "$SCRIPT_DIR/../packages/arch/essential.txt"

# Install rustup for building AUR packages
if ! command -v rustc &>/dev/null; then
  log_info "Installing Rust toolchain..."
  sudo pacman -S --needed --noconfirm rustup
  rustup default stable
fi

# Install paru (AUR helper)
if ! command -v paru &>/dev/null; then
  log_info "Installing paru (AUR helper)..."
  
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/paru-git.git "$tmpdir/paru"
  (cd "$tmpdir/paru" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
  
  log_success "paru installed"
fi

log_success "Essential packages installed"
