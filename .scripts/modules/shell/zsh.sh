#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"
source "$DOTFILES_DIR/.scripts/lib/pkg.sh"

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

setup_zinit() {
    local zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

    log_step "Setting up zinit plugin manager..."

    if [[ -d "$zinit_home" ]]; then
        log_skip "zinit already installed"
        return 0
    fi

    log_info "Installing zinit..."
    ensure_dir "$(dirname "$zinit_home")"
    run git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home"

    log_success "zinit installed"
}

change_default_shell() {
    local current_shell=$(basename "$SHELL")

    if [[ "$current_shell" == "zsh" ]]; then
        log_skip "ZSH is already the default shell"
        return 0
    fi

    log_step "Changing default shell to ZSH..."

    if confirm "Make ZSH the default shell?" true; then
        local zsh_path=$(which zsh)

        if ! grep -q "^$zsh_path$" /etc/shells; then
            log_info "Adding ZSH to /etc/shells..."
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi

        run chsh -s "$zsh_path"
        log_success "Default shell changed to ZSH"
        log_info "Please log out and log back in for changes to take effect"
    else
        log_skip "Keeping current shell: $current_shell"
    fi
}

main() {
    header "ZSH Setup"

    install_zsh
    setup_zinit
    change_default_shell

    log_success "ZSH setup complete!"
    log_info "Dotfiles already contain ZSH configuration"
    log_info "Restart your shell or run: exec zsh"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
