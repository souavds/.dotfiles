#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Security Setup"

if ! confirm "Setup firewall (ufw)?"; then
  log_info "Skipping firewall setup"
  exit 0
fi

log_info "Installing ufw..."
paru -S --needed --noconfirm ufw

log_info "Configuring firewall rules..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo systemctl enable --now ufw
sudo ufw enable

log_success "Firewall configured and enabled"
log_success "Security setup complete"
