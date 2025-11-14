#!/usr/bin/env bash

# Bootstrap script - installs minimal dependencies needed to run the installer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)" pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"

bootstrap_arch() {
    log_step "Bootstrapping Arch Linux..."
    
    # Ensure sudo is available
    if ! command_exists sudo; then
        log_error "sudo is required but not installed"
        return 1
    fi
    
    # Update package database
    log_info "Updating package database..."
    sudo pacman -Sy --noconfirm
    
    # Install base-devel if not present (needed for AUR)
    if ! pacman -Qg base-devel &>/dev/null; then
        log_info "Installing base-devel..."
        sudo pacman -S --needed --noconfirm base-devel
    fi
    
    # Install paru if not present
    if ! command_exists paru && ! command_exists yay; then
        log_info "Installing paru (AUR helper)..."
        
        # Install rust first
        if ! command_exists rustc; then
            sudo pacman -S --needed --noconfirm rustup
            rustup default stable
        fi
        
        # Clone and build paru
        local tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/paru-git.git "$tmpdir/paru"
        (cd "$tmpdir/paru" && makepkg -si --noconfirm)
        rm -rf "$tmpdir"
    fi
    
    log_success "Arch Linux bootstrap complete"
}

bootstrap_darwin() {
    log_step "Bootstrapping macOS..."
    
    # Install Homebrew if not present
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add brew to PATH for this session
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    # Update brew
    brew update
    
    log_success "macOS bootstrap complete"
}

main() {
    header "Bootstrap"
    
    log_info "Platform: $PLATFORM"
    log_info "Distro: $DISTRO"
    
    case "$PLATFORM" in
        linux)
            if [[ "$DISTRO" == "arch" ]]; then
                bootstrap_arch
            else
                log_error "Unsupported Linux distribution: $DISTRO"
                return 1
            fi
            ;;
        darwin)
            bootstrap_darwin
            ;;
        *)
            log_error "Unsupported platform: $PLATFORM"
            return 1
            ;;
    esac
    
    log_success "Bootstrap complete!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
