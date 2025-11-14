#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"
source "$DOTFILES_DIR/.scripts/lib/yaml.sh"
source "$DOTFILES_DIR/.scripts/lib/pkg.sh"

install_category() {
    local category="$1"
    local display_name="${2:-$category}"

    local packages=$(get_all_packages "$category")

    if [[ -z "$packages" ]]; then
        return 0
    fi

    header "Installing $display_name packages"

    log_info "Packages to install:"
    echo "$packages" | sed 's/^/  - /'
    echo

    if [[ "$DRY_RUN" != "true" ]] && ! confirm "Install these packages?" true; then
        log_skip "Skipped $category packages"
        return 0
    fi

    local to_install=()
    local already_installed=()

    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue

        if pkg_is_installed "$pkg"; then
            already_installed+=("$pkg")
        else
            to_install+=("$pkg")
        fi
    done <<<"$packages"

    if [[ ${#already_installed[@]} -gt 0 ]]; then
        log_info "Already installed: ${already_installed[*]}"
    fi

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

main() {
    header "Package Installation"

    log_step "Updating package database..."
    pkg_update

    install_category "essential"
    install_category "shell"

    if confirm "Install development tools?" true; then
        install_category "dev"
    fi

    if confirm "Install terminal emulators?" true; then
        install_category "terminals"
    fi

    case "$PLATFORM" in
    linux)
        if [[ "$DISTRO" == "arch" ]]; then
            if confirm "Install Arch-specific packages?" true; then
                install_category "packages" "Arch-specific"
                install_category "fonts" "fonts"
                install_category "nerd_fonts" "Nerd Fonts"
            fi

            if confirm "Install AUR packages?" false; then
                install_category "aur" "AUR"
            fi
        fi
        ;;
    darwin)
        if confirm "Install macOS-specific packages?" true; then
            install_category "brew" "Homebrew"
            install_category "cask" "Homebrew Cask"
        fi
        ;;
    esac

    log_success "Package installation complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
