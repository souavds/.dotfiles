#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"
source "$DOTFILES_DIR/.scripts/lib/pkg.sh"

install_dependencies() {
    header "Installing Language Dependencies"

    case "$PLATFORM" in
    linux)
        if [[ "$DISTRO" == "arch" ]]; then
            log_info "Installing Erlang/Elixir dependencies..."
            pkg_install jdk-openjdk unixodbc ncurses libssh wxwidgets-gtk3 wxwidgets-common unzip
        fi
        ;;
    darwin)
        log_info "Installing Erlang/Elixir dependencies..."
        pkg_install openjdk unixodbc
        ;;
    esac

    log_success "Dependencies installed"
}

ensure_mise() {
    if ! command_exists mise; then
        log_error "mise not found. Please install it first via package manager"
        return 1
    fi

    log_success "mise is available"
}

install_languages() {
    header "Installing Programming Languages"

    log_step "Installing Node.js..."
    if mise list node &>/dev/null && mise list node | grep -q "node"; then
        log_skip "Node.js already installed"
    else
        run mise use --global node@latest
        log_success "Node.js installed"
    fi

    log_step "Installing Erlang..."
    if mise list erlang &>/dev/null && mise list erlang | grep -q "erlang"; then
        log_skip "Erlang already installed"
    else
        export KERL_CONFIGURE_OPTIONS="--enable-wx"
        run mise use --global erlang@latest
        log_success "Erlang installed"
    fi

    log_step "Installing Elixir..."
    if mise list elixir &>/dev/null && mise list elixir | grep -q "elixir"; then
        log_skip "Elixir already installed"
    else
        run mise use --global elixir@latest
        log_success "Elixir installed"
    fi

    log_step "Installing usage (Elixir CLI tool)..."
    if mise list usage &>/dev/null && mise list usage | grep -q "usage"; then
        log_skip "usage already installed"
    else
        run mise use --global usage@latest
        log_success "usage installed"
    fi

    log_success "All languages installed"
}

main() {
    header "Language Setup"

    ensure_mise
    install_dependencies
    install_languages

    log_success "Language setup complete!"
    log_info "Run 'mise doctor' to verify installation"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
