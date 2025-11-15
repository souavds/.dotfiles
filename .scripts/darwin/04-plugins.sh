#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Installing Plugins"

# Tmux Plugin Manager (TPM)
if [[ -f "$HOME/.config/tmux/tmux.conf" ]] || [[ -f "$HOME/.tmux.conf" ]]; then
  log_info "Installing tmux plugins..."
  
  # Install TPM if not present
  if [[ ! -d "$HOME/.config/tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
  fi
  
  # Install plugins headlessly
  if command -v tmux &>/dev/null; then
    "$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
    log_success "tmux plugins installed"
  fi
else
  log_warn "tmux config not found, skipping tmux plugins"
fi

# Neovim plugins
if command -v nvim &>/dev/null; then
  log_info "Installing neovim plugins..."
  
  # Run headless nvim to trigger lazy.nvim installation
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  
  log_success "neovim plugins installed"
else
  log_warn "neovim not found, skipping nvim plugins"
fi

log_success "Plugin installation complete"
log_info "Note: Some plugins may need additional setup on first use"
