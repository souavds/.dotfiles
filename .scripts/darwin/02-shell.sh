set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Shell Setup"

if ! command -v zsh &>/dev/null; then
  log_info "Installing zsh..."
  brew install zsh
fi

if confirm "Set zsh as default shell for $USER?"; then
  chsh -s "$(which zsh)"
  log_success "zsh set as default shell (requires re-login)"
fi

log_success "Shell setup complete"
