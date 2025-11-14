#!/usr/bin/env bash

# Programming language installation via mise
# Sets up Node, Erlang, Elixir, and other dev tools

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

# Install language dependencies
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

# Setup mise if not installed
ensure_mise() {
    if ! command_exists mise; then
        log_error "mise not found. Please install it first via package manager"
        return 1
    fi
    
    log_success "mise is available"
}

# Install languages via mise
install_languages() {
    header "Installing Programming Languages"
    
    log_step "Installing Node.js..."
    if mise list node &>/dev/null && mise list node | grep -q "node"; then
        log_skip "Node.js already installed"
    else
        run mise use -g node@latest
        log_success "Node.js installed"
    fi
    
    log_step "Installing Erlang (with wxWidgets)..."
    if mise list erlang &>/dev/null && mise list erlang | grep -q "erlang"; then
        log_skip "Erlang already installed"
    else
        export KERL_CONFIGURE_OPTIONS="--enable-wx"
        run mise use -g erlang@latest
        log_success "Erlang installed"
    fi
    
    log_step "Installing Elixir..."
    if mise list elixir &>/dev/null && mise list elixir | grep -q "elixir"; then
        log_skip "Elixir already installed"
    else
        run mise use -g elixir@latest
        log_success "Elixir installed"
    fi
    
    log_step "Reshimming mise..."
    run mise reshim
    
    log_success "All languages installed"
}

# Install shell tools via mise
install_shell_tools() {
    header "Installing Shell Tools"
    
    log_step "Installing usage (shell completion)..."
    if mise list usage &>/dev/null && mise list usage | grep -q "usage"; then
        log_skip "usage already installed"
    else
        run mise use -g usage@latest
        log_success "usage installed"
    fi
}

# Main installation
main() {
    header "Language Runtime Setup"
    
    ensure_mise
    
    if confirm "Install language dependencies?" true; then
        install_dependencies
    fi
    
    if confirm "Install programming languages (Node, Erlang, Elixir)?" true; then
        install_languages
    fi
    
    if confirm "Install shell completion tools?" true; then
        install_shell_tools
    fi
    
    log_success "Language setup complete"
    log_info "You may need to restart your shell for changes to take effect"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
