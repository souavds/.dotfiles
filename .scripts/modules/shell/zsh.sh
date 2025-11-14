#!/usr/bin/env bash

# ZSH setup module
# Installs and configures ZSH with zinit plugin manager

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"

# Load platform-specific package manager
case "$PLATFORM" in
    linux)
        [[ "$DISTRO" == "arch" ]] && source "$DOTFILES_DIR/.scripts/platforms/arch/package-manager.sh"
        ;;
    darwin)
        source "$DOTFILES_DIR/.scripts/platforms/darwin/package-manager.sh"
        ;;
esac

# Install ZSH if not present
install_zsh() {
    log_step "Checking ZSH installation..."
    
    if command_exists zsh; then
        log_skip "ZSH already installed"
        return 0
    fi
    
    log_info "Installing ZSH..."
    pkg_install zsh
    log_success "ZSH installed"
}

# Setup zinit plugin manager
setup_zinit() {
    local zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
    
    log_step "Setting up zinit plugin manager..."
    
    if [[ -d "$zinit_home" ]]; then
        log_skip "zinit already installed"
        return 0
    fi
    
    log_info "Installing zinit..."
    ensure_dir "$(dirname "$zinit_home")"
    
    if run git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home"; then
        log_success "zinit installed to $zinit_home"
    else
        log_error "Failed to install zinit"
        return 1
    fi
}

# Set ZSH as default shell
set_default_shell() {
    log_step "Checking default shell..."
    
    local current_shell=$(basename "$SHELL")
    
    if [[ "$current_shell" == "zsh" ]]; then
        log_skip "ZSH is already the default shell"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would change shell to zsh"
        return 0
    fi
    
    if ! confirm "Set ZSH as default shell?" true; then
        log_skip "Keeping current shell: $current_shell"
        return 0
    fi
    
    local zsh_path=$(which zsh)
    
    # Add to /etc/shells if not present
    if ! grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
        log_info "Adding ZSH to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    
    log_info "Changing default shell to ZSH..."
    if chsh -s "$zsh_path"; then
        log_success "Default shell changed to ZSH"
        log_warning "You need to log out and back in for the change to take effect"
    else
        log_error "Failed to change default shell"
        return 1
    fi
}

# Main installation
main() {
    header "ZSH Setup"
    
    install_zsh
    setup_zinit
    set_default_shell
    
    log_success "ZSH setup complete"
    log_info "ZSH plugins will be installed on first launch"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
