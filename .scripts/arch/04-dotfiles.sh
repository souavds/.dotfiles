#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Dotfiles Setup"

# Stow dotfiles
if confirm "Symlink dotfiles using stow?"; then
  log_info "Creating symlinks..."
  
  cd "$DOTFILES_DIR"
  stow --adopt -v .
  
  log_success "Dotfiles symlinked"
fi

# Setup .gitconfig.local
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  if confirm "Setup git local configuration?"; then
    if [[ -f "$DOTFILES_DIR/.gitconfig.local.template" ]]; then
      name=$(read_input "Your full name" "Your Name")
      email=$(read_input "Your email" "you@example.com")
      
      cat > "$HOME/.gitconfig.local" << GITEOF
[user]
	email = $email
	name = $name

# Uncomment and configure if using 1Password SSH signing:
# [user]
#	signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...
#
# [gpg "ssh"]
#	program = "/opt/1Password/op-ssh-sign"
GITEOF
      
      log_success "Git local config created at $HOME/.gitconfig.local"
    fi
  fi
fi

log_success "Dotfiles setup complete"
