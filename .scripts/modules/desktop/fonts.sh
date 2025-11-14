#!/usr/bin/env bash

# Installs Nerd Fonts from GitHub releases

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"
source "$DOTFILES_DIR/.scripts/lib/yaml.sh"

# Determine font directory based on platform
get_font_dir() {
    case "$PLATFORM" in
        linux)
            echo "$HOME/.local/share/fonts"
            ;;
        darwin)
            echo "$HOME/Library/Fonts"
            ;;
        *)
            echo "$HOME/.fonts"
            ;;
    esac
}

# Check if font is already installed
is_font_installed() {
    local font_name="$1"
    local font_dir=$(get_font_dir)
    
    # Check if directory exists with font files
    if [[ -d "$font_dir/$font_name" ]] && [[ -n "$(find "$font_dir/$font_name" -name "*.ttf" -o -name "*.otf" 2>/dev/null)" ]]; then
        return 0
    fi
    
    return 1
}

# Download and install a Nerd Font
install_nerd_font() {
    local font_name="$1"
    local font_dir=$(get_font_dir)
    local tmp_dir="$DOTFILES_DIR/tmp/fonts"
    
    if is_font_installed "$font_name"; then
        log_skip "$font_name already installed"
        return 0
    fi
    
    log_step "Downloading $font_name..."
    
    ensure_dir "$tmp_dir"
    ensure_dir "$font_dir"
    
    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
    local zip_file="$tmp_dir/${font_name}.zip"
    
    # Download font
    if ! run curl -fsSL --create-dirs -o "$zip_file" "$download_url"; then
        log_error "Failed to download $font_name"
        return 1
    fi
    
    # Extract to font directory
    log_info "Installing $font_name..."
    ensure_dir "$font_dir/$font_name"
    
    if ! run unzip -q -o "$zip_file" -d "$font_dir/$font_name"; then
        log_error "Failed to extract $font_name"
        return 1
    fi
    
    # Cleanup
    rm -f "$zip_file"
    
    log_success "$font_name installed"
}

# Refresh font cache
refresh_font_cache() {
    log_step "Refreshing font cache..."
    
    case "$PLATFORM" in
        linux)
            if command_exists fc-cache; then
                run fc-cache -f
                log_success "Font cache refreshed"
            else
                log_warning "fc-cache not found, font cache not refreshed"
            fi
            ;;
        darwin)
            log_info "macOS will refresh font cache automatically"
            ;;
    esac
}

# Main installation
main() {
    header "Font Installation"
    
    # Check for required commands
    if ! command_exists curl; then
        log_error "curl is required but not installed"
        return 1
    fi
    
    if ! command_exists unzip; then
        log_error "unzip is required but not installed"
        return 1
    fi
    
    # Get font list from YAML
    local fonts=()
    while IFS= read -r font; do
        [[ -n "$font" ]] && fonts+=("$font")
    done < <(yaml_array "$CONFIG_DIR/packages.yml" "nerd_fonts")
    
    if [[ ${#fonts[@]} -eq 0 ]]; then
        log_warning "No fonts defined in packages.yml"
        return 0
    fi
    
    log_info "Available fonts:"
    printf '  - %s\n' "${fonts[@]}"
    echo
    
    # Ask which fonts to install
    local selected_fonts
    if [[ "$DRY_RUN" != "true" ]]; then
        if confirm "Install all fonts?" false; then
            selected_fonts=("${fonts[@]}")
        else
            log_info "Select fonts to install (use gum/interactive selection)"
            selected_fonts=($(choose "Select fonts to install:" "${fonts[@]}"))
        fi
    else
        selected_fonts=("${fonts[@]}")
    fi
    
    if [[ ${#selected_fonts[@]} -eq 0 ]]; then
        log_skip "No fonts selected"
        return 0
    fi
    
    # Install selected fonts
    local failed=()
    for font in "${selected_fonts[@]}"; do
        if install_nerd_font "$font"; then
            log_success "✓ $font"
        else
            failed+=("$font")
        fi
    done
    
    # Refresh font cache
    refresh_font_cache
    
    # Cleanup temp directory
    rm -rf "$DOTFILES_DIR/tmp/fonts"
    
    # Report results
    echo
    if [[ ${#failed[@]} -gt 0 ]]; then
        log_warning "Failed to install: ${failed[*]}"
        return 1
    else
        log_success "All fonts installed successfully"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
