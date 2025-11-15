#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Shell Setup"

# Install zsh (usually pre-installed on macOS)
if ! command -v zsh &>/dev/null; then
  log_info "Installing zsh..."
  brew install zsh
fi

# Set zsh as default shell
if confirm "Set zsh as default shell for $USER?"; then
  chsh -s "$(which zsh)"
  log_success "zsh set as default shell (requires re-login)"
fi

log_success "Shell setup complete"
