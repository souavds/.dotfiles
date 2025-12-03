#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

sudo pacman -S gum

log_header "Installing Essential Packages"

log_info "Updating package database..."
sudo pacman -Sy --noconfirm

packages=()
while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  packages+=("$pkg")
done < "$SCRIPT_DIR/../packages/arch/essential"

log_info "Installing essential packages..."
sudo pacman -S --needed --noconfirm "${packages[@]}"

if ! command -v rustc &>/dev/null; then
  log_info "Installing Rust toolchain..."
  sudo pacman -S --needed --noconfirm rustup
  rustup default stable
fi

if ! command -v paru &>/dev/null; then
  log_info "Installing paru (AUR helper)..."
  
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/paru-git.git "$tmpdir/paru"
  (cd "$tmpdir/paru" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
  
  log_success "paru installed"
fi

log_success "Essential packages installed"
