set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Shell Setup"

log_info "Installing zsh..."
paru -S --needed --noconfirm zsh

if confirm "Set zsh as default shell for $USER?"; then
  chsh -s "$(which zsh)"
  log_success "zsh set as default shell (requires re-login)"
fi

log_success "Shell setup complete"
