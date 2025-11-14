#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"
source "$DOTFILES_DIR/.scripts/lib/pkg.sh"

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

setup_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    log_step "Setting up TPM (Tmux Plugin Manager)..."

    if [[ -d "$tpm_dir" ]]; then
        log_skip "TPM already installed"
        return 0
    fi

    log_info "Cloning TPM repository..."
    run git clone https://github.com/tmux-plugins/tpm "$tpm_dir"

    log_success "TPM installed"
    log_info "Start tmux and press Ctrl+A + I to install plugins"
}

main() {
    header "Tmux Setup"

    install_tmux
    setup_tpm

    log_success "Tmux setup complete!"
    log_info "Dotfiles already contain tmux configuration"
    log_info "Start tmux and press Ctrl+A + I to install plugins"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
