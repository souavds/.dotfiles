#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Laptop Tools Setup"

if ! confirm "Is this a laptop? Install laptop-specific tools?"; then
  log_info "Skipping laptop tools"
  exit 0
fi

# Thermald
log_info "Installing thermald..."
paru -S --needed --noconfirm thermald
sudo systemctl enable --now thermald.service
log_success "thermald configured"

# ACPI
log_info "Installing acpi..."
paru -S --needed --noconfirm acpi
sudo systemctl enable --now acpid.service
log_success "acpid configured"

# auto-cpufreq
log_info "Installing auto-cpufreq..."
paru -S --needed --noconfirm auto-cpufreq

if confirm "Enable auto-cpufreq service?"; then
  sudo systemctl enable --now auto-cpufreq
  log_success "auto-cpufreq enabled"
fi

# Intel microcode
if confirm "Install Intel microcode?"; then
  paru -S --needed --noconfirm intel-ucode
  log_success "Intel microcode installed"
fi

# Firmware updates
log_info "Installing fwupd..."
paru -S --needed --noconfirm fwupd
sudo systemctl enable --now fwupd-refresh.timer
log_info "Run 'fwupdmgr update' manually to update firmware"

# Fingerprint reader
if confirm "Setup fingerprint reader (fprintd)?"; then
  paru -S --needed --noconfirm fprintd
  
  log_info "Enrolling fingerprint..."
  fprintd-enroll
  fprintd-verify
  
  # Copy PAM configuration
  if [[ -f "$SCRIPT_DIR/../../.cp/pam.d/system-local-login" ]]; then
    sudo cp "$SCRIPT_DIR/../../.cp/pam.d/system-local-login" /etc/pam.d/system-local-login
    sudo cp "$SCRIPT_DIR/../../.cp/pam.d/polkit-1" /etc/pam.d/polkit-1
    log_success "PAM configuration updated"
  fi
fi

# Lid management
if confirm "Configure lid management?"; then
  if [[ -d "$SCRIPT_DIR/../../.cp/systemd/logind.conf.d" ]]; then
    sudo cp -r "$SCRIPT_DIR/../../.cp/systemd/logind.conf.d/" /etc/systemd/
    log_success "Lid management configured"
  fi
fi

log_success "Laptop tools setup complete"
