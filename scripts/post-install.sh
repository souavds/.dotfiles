#!/usr/bin/env bash

# Post-installation tasks
# Runs after main installation is complete

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_DIR/lib/core.sh"
source "$DOTFILES_DIR/lib/ui.sh"

main() {
    header "Post-Installation"
    
    # Setup ZSH plugins
    if command_exists zsh; then
        log_step "Checking ZSH setup..."
        
        local zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
        
        if [[ ! -d "$zinit_home" ]]; then
            log_info "Installing zinit plugin manager..."
            mkdir -p "$(dirname "$zinit_home")"
            git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home"
            log_success "zinit installed"
        else
            log_skip "zinit already installed"
        fi
    fi
    
    # Setup Tmux plugins
    if command_exists tmux; then
        log_step "Checking Tmux setup..."
        
        if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
            log_info "Installing Tmux Plugin Manager..."
            git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
            log_success "TPM installed"
            log_info "Run 'tmux' and press Ctrl+A + I to install tmux plugins"
        else
            log_skip "TPM already installed"
        fi
    fi
    
    # Cleanup
    log_step "Cleaning up temporary files..."
    rm -rf "$DOTFILES_DIR/tmp"
    
    log_success "Post-installation complete!"
    
    echo
    header "Next Steps"
    echo "1. Restart your shell or run: exec zsh"
    echo "2. Open tmux and press Ctrl+A + I to install plugins"
    echo "3. Run 'nvim' to let plugins install automatically"
    echo "4. Review logs at: $LOG_FILE"
    echo
    
    if [[ "$PLATFORM" == "linux" ]] && [[ "$DISTRO" == "arch" ]]; then
        echo "Arch Linux specific:"
        echo "  - Run 'fwupdmgr update' to update firmware"
        echo "  - Run 'fprintd-enroll' to setup fingerprint (if hardware present)"
        echo
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
