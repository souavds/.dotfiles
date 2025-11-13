#!/usr/bin/env bash

# Arch Linux package manager abstraction
# Handles pacman and AUR helpers (paru/yay)

source "$DOTFILES_DIR/lib/core.sh"

# Determine which package manager to use
pkg_manager() {
    if command_exists paru; then
        echo "paru"
    elif command_exists yay; then
        echo "yay"
    else
        echo "pacman"
    fi
}

# Install packages
pkg_install() {
    local manager=$(pkg_manager)
    local packages=("$@")
    
    case "$manager" in
        paru|yay)
            run $manager -S --needed --noconfirm "${packages[@]}"
            ;;
        pacman)
            run sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
    esac
}

# Update system
pkg_update() {
    local manager=$(pkg_manager)
    
    case "$manager" in
        paru|yay)
            run $manager -Syu --noconfirm
            ;;
        pacman)
            run sudo pacman -Syu --noconfirm
            ;;
    esac
}

# Check if package is installed
pkg_is_installed() {
    pacman -Qi "$1" &>/dev/null
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
    run sudo pacman -Rsn --noconfirm "$@"
}
