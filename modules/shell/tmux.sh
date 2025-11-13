#!/usr/bin/env bash

# Tmux setup module
# Installs and configures Tmux with TPM (Tmux Plugin Manager)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/lib/core.sh"
source "$DOTFILES_DIR/lib/ui.sh"

# Load platform-specific package manager
case "$PLATFORM" in
    linux)
        [[ "$DISTRO" == "arch" ]] && source "$DOTFILES_DIR/platforms/arch/package-manager.sh"
        ;;
    darwin)
        source "$DOTFILES_DIR/platforms/darwin/package-manager.sh"
        ;;
esac

# Install Tmux if not present
install_tmux() {
    log_step "Checking Tmux installation..."
    
    if command_exists tmux; then
        log_skip "Tmux already installed"
        return 0
    fi
    
    log_info "Installing Tmux..."
    pkg_install tmux
    log_success "Tmux installed"
}

# Setup TPM (Tmux Plugin Manager)
setup_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    
    log_step "Setting up TPM (Tmux Plugin Manager)..."
    
    if [[ -d "$tpm_dir" ]]; then
        log_skip "TPM already installed"
        return 0
    fi
    
    log_info "Installing TPM..."
    ensure_dir "$HOME/.tmux/plugins"
    
    if run git clone https://github.com/tmux-plugins/tpm "$tpm_dir"; then
        log_success "TPM installed to $tpm_dir"
    else
        log_error "Failed to install TPM"
        return 1
    fi
}

# Main installation
main() {
    header "Tmux Setup"
    
    install_tmux
    setup_tpm
    
    log_success "Tmux setup complete"
    echo
    log_info "Next steps:"
    log_info "  1. Start tmux: tmux"
    log_info "  2. Install plugins: Press Ctrl+A (prefix) then I (capital i)"
    log_info "  3. Reload config: Press Ctrl+A then r"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
