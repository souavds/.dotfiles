#!/usr/bin/env bash

# Post-installation tasks
# Runs after main installation is complete

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)" pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"

main() {
    header "Post-Installation"
    
    # Setup git config local file if it doesn't exist
    if [[ ! -f "$HOME/.gitconfig.local" ]]; then
        log_step "Setting up git local configuration..."
        
        if [[ -f "$DOTFILES_DIR/.gitconfig.local.template" ]]; then
            if [[ "$DRY_RUN" != "true" ]]; then
                local name=$(input "Your full name" "Your Name")
                local email=$(input "Your email" "you@example.com")
                
                cat > "$HOME/.gitconfig.local" <<EOF
[user]
	email = $email
	name = $name

# Uncomment and configure if using 1Password SSH signing:
# [user]
#	signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...
#
# [gpg "ssh"]
#	program = "/opt/1Password/op-ssh-sign"
EOF
                log_success "Created ~/.gitconfig.local"
            else
                log_info "[DRY-RUN] Would create ~/.gitconfig.local"
            fi
        fi
    else
        log_skip "~/.gitconfig.local already exists"
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
    echo "4. Edit ~/.gitconfig.local if you need SSH signing"
    echo "5. Review logs at: $LOG_FILE"
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
