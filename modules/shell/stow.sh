#!/usr/bin/env bash

# Dotfiles symlinking module using GNU Stow
# Manages dotfile symlinks safely

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/lib/core.sh"
source "$DOTFILES_DIR/lib/ui.sh"
source "$DOTFILES_DIR/lib/backup.sh"

# Check if already stowed
is_stowed() {
    # Check if common dotfiles are symlinks pointing to this repo
    [[ -L "$HOME/.zshrc" ]] && [[ "$(readlink -f "$HOME/.zshrc")" == "$DOTFILES_DIR/.zshrc" ]]
}

# Main stow operation
main() {
    header "Dotfiles Symlinking"
    
    cd "$DOTFILES_DIR" || error "Failed to cd to $DOTFILES_DIR"
    
    if is_stowed; then
        log_info "Dotfiles already linked"
        
        if confirm "Re-stow dotfiles?" false; then
            log_step "Re-stowing dotfiles..."
            run stow -R -v .
            log_success "Dotfiles re-stowed"
        fi
    else
        log_step "Preparing to symlink dotfiles..."
        
        # Check for conflicts
        local conflicts=()
        
        for file in .zshrc .gitconfig .ripgreprc; do
            if [[ -f "$HOME/$file" ]] && [[ ! -L "$HOME/$file" ]]; then
                conflicts+=("$file")
            fi
        done
        
        if [[ ${#conflicts[@]} -gt 0 ]]; then
            log_warning "The following files will be overwritten:"
            printf '  %s\n' "${conflicts[@]}"
            echo
            
            if ! confirm "Create backup and continue?" true; then
                log_info "Stow cancelled"
                return 1
            fi
            
            backup_create "pre-stow-$(date +%Y%m%d-%H%M%S)"
        fi
        
        log_step "Symlinking dotfiles..."
        
        # Remove old dotfiles and stow
        if [[ "$DRY_RUN" != "true" ]]; then
            run stow -D . 2>/dev/null || true
            run stow -v .
        else
            log_info "[DRY-RUN] Would run: stow -D . && stow -v ."
        fi
        
        log_success "Dotfiles symlinked successfully"
    fi
    
    # Verify critical symlinks
    log_step "Verifying symlinks..."
    
    local expected_links=(
        "$HOME/.zshrc"
        "$HOME/.gitconfig"
        "$HOME/.config/nvim"
        "$HOME/.config/tmux"
    )
    
    local missing=()
    
    for link in "${expected_links[@]}"; do
        if [[ ! -e "$link" ]]; then
            missing+=("$link")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warning "Missing symlinks:"
        printf '  %s\n' "${missing[@]}"
    else
        log_success "All expected symlinks verified"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
