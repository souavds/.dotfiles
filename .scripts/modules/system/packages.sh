#!/usr/bin/env bash

# Installs packages from YAML manifests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"
source "$DOTFILES_DIR/.scripts/lib/yaml.sh"

# Load platform-specific package manager
case "$PLATFORM" in
    linux)
        if [[ "$DISTRO" == "arch" ]]; then
            source "$DOTFILES_DIR/.scripts/platforms/arch/package-manager.sh"
        fi
        ;;
    darwin)
        source "$DOTFILES_DIR/.scripts/platforms/darwin/package-manager.sh"
        ;;
esac

# Install packages from a category
install_category() {
    local category="$1"
    
    header "Installing $category packages"
    
    local packages=$(get_all_packages "$category")
    
    if [[ -z "$packages" ]]; then
        log_info "No packages in category: $category"
        return 0
    fi
    
    log_info "Packages to install:"
    echo "$packages" | sed 's/^/  - /'
    echo
    
    if [[ "$DRY_RUN" != "true" ]] && ! confirm "Install these packages?" true; then
        log_skip "Skipped $category packages"
        return 0
    fi
    
    # Filter out already installed packages and collect ones to install
    local to_install=()
    local already_installed=()
    
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        
        if pkg_is_installed "$pkg"; then
            already_installed+=("$pkg")
        else
            to_install+=("$pkg")
        fi
    done <<< "$packages"
    
    # Show already installed
    if [[ ${#already_installed[@]} -gt 0 ]]; then
        log_info "Already installed: ${already_installed[*]}"
    fi
    
    # Batch install new packages
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All $category packages already installed"
        return 0
    fi
    
    log_step "Installing ${#to_install[@]} package(s)..."
    
    if pkg_install "${to_install[@]}"; then
        log_success "All $category packages installed"
    else
        log_error "Some packages failed to install"
        return 1
    fi
}

# Main installation
main() {
    header "Package Installation"
    
    # Update package database
    log_step "Updating package database..."
    pkg_update
    
    # Install essential packages first
    install_category "essential"
    
    # Install shell utilities
    install_category "shell"
    
    # Ask about development tools
    if confirm "Install development tools?" true; then
        install_category "dev"
    fi
    
    # Ask about terminals
    if confirm "Install terminal emulators?" true; then
        install_category "terminals"
    fi
    
    # Platform-specific packages
    case "$PLATFORM" in
        linux)
            if [[ "$DISTRO" == "arch" ]]; then
                if confirm "Install Arch-specific packages?" true; then
                    install_category "packages"
                    install_category "fonts"
                    install_category "nerd_fonts"
                fi
                
                if confirm "Install AUR packages?" false; then
                    install_category "aur"
                fi
            fi
            ;;
        darwin)
            if confirm "Install macOS-specific packages?" true; then
                install_category "brew"
                install_category "cask"
            fi
            ;;
    esac
    
    log_success "Package installation complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
