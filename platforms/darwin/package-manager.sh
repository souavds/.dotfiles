#!/usr/bin/env bash

# macOS package manager abstraction
# Handles Homebrew

source "$DOTFILES_DIR/lib/core.sh"

# Install packages
pkg_install() {
    run brew install "$@"
}

# Update system
pkg_update() {
    run brew update
    run brew upgrade
}

# Check if package is installed
pkg_is_installed() {
    brew list --formula | grep -q "^$1$" || brew list --cask | grep -q "^$1$"
}

# Install package if not already installed
pkg_ensure() {
    local pkg="$1"
    
    if pkg_is_installed "$pkg"; then
        log_skip "$pkg already installed"
        return 0
    fi
    
    log_info "Installing $pkg..."
    pkg_install "$pkg"
}

# Remove packages
pkg_remove() {
    run brew uninstall "$@"
}

# Install cask (GUI app)
pkg_install_cask() {
    run brew install --cask "$@"
}
