#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Setting up greet and compositor"

log_info "Installing niri..."
paru -S --needed --noconfirm niri 

log_info "Installing ly..."

paru -S --needed --noconfirm ly 
sudo systemctl enable ly.service

log_info "Cleaning up niri dependencies..."

paru -Rsn --noconfirm waybar fuzzel

log_success "Greet and compositor installed"
