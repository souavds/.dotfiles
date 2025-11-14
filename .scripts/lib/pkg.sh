#!/usr/bin/env bash

# Unified package manager abstraction for Arch Linux (pacman/paru) and macOS (Homebrew)

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

pkg_install() {
  local packages=("$@")

  case "$PLATFORM" in
    linux)
      if command_exists paru; then
        run paru -S --needed --noconfirm "${packages[@]}"
      elif command_exists yay; then
        run yay -S --needed --noconfirm "${packages[@]}"
      else
        run sudo pacman -S --needed --noconfirm "${packages[@]}"
      fi
      ;;
    darwin)
      run brew install "${packages[@]}"
      ;;
    *)
      error "Unsupported platform: $PLATFORM"
      ;;
  esac
}

pkg_update() {
  case "$PLATFORM" in
    linux)
      if command_exists paru; then
        run paru -Sy --noconfirm
      elif command_exists yay; then
        run yay -Sy --noconfirm
      else
        run sudo pacman -Sy --noconfirm
      fi
      ;;
    darwin)
      run brew update
      ;;
    *)
      error "Unsupported platform: $PLATFORM"
      ;;
  esac
}

pkg_is_installed() {
  local pkg="$1"

  case "$PLATFORM" in
    linux)
      pacman -Qi "$pkg" &>/dev/null
      ;;
    darwin)
      brew list --formula 2>/dev/null | grep -q "^$pkg$" \
        || brew list --cask 2>/dev/null | grep -q "^$pkg$"
      ;;
    *)
      return 1
      ;;
  esac
}

pkg_ensure() {
  local pkg="$1"

  if pkg_is_installed "$pkg"; then
    log_skip "$pkg already installed"
    return 0
  fi

  log_info "Installing $pkg..."
  pkg_install "$pkg"
}
