#!/usr/bin/env bash

# Package installation module
# Installs packages from YAML manifests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/lib/core.sh"
source "$DOTFILES_DIR/lib/ui.sh"
source "$DOTFILES_DIR/lib/yaml.sh"

# Load platform-specific package manager
case "$PLATFORM" in
    linux)
        if [[ "$DISTRO" == "arch" ]]; then
            source "$DOTFILES_DIR/platforms/arch/package-manager.sh"
        fi
        ;;
    darwin)
        source "$DOTFILES_DIR/platforms/darwin/package-manager.sh"
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
    
    local failed=()
    
    while IFS= read -r pkg; do
        if [[ -z "$pkg" ]]; then
            continue
        fi
        
        if pkg_ensure "$pkg"; then
            log_success "Installed: $pkg"
        else
            log_error "Failed to install: $pkg"
            failed+=("$pkg")
        fi
    done <<< "$packages"
    
    if [[ ${#failed[@]} -gt 0 ]]; then
        log_warning "Failed packages: ${failed[*]}"
        return 1
    fi
    
    log_success "All $category packages installed"
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
