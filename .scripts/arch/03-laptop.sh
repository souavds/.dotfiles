#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Laptop Tools Setup"

if ! confirm "Is this a laptop? Install laptop-specific tools?"; then
  log_info "Skipping laptop tools"
  exit 0
fi

packages=(thermald acpi auto-cpufreq fwupd)

install_intel_microcode=false
if confirm "Install Intel microcode?"; then
  packages+=(intel-ucode)
  install_intel_microcode=true
fi

setup_fingerprint=false
if confirm "Setup fingerprint reader (fprintd)?"; then
  packages+=(fprintd)
  setup_fingerprint=true
fi

log_info "Installing laptop tools..."
paru -S --needed --noconfirm "${packages[@]}"

log_info "Enabling services..."
sudo systemctl enable --now thermald.service
sudo systemctl enable --now fwupd-refresh.timer

if confirm "Enable auto-cpufreq service?"; then
  sudo systemctl enable --now auto-cpufreq
  sudo auto-cpufreq --bluetooth_boot_off
  log_success "auto-cpufreq enabled"
fi

if confirm "Configure lid management?"; then
  if [[ -d "$SCRIPT_DIR/../../.cp/systemd/logind.conf.d" ]]; then
    sudo cp -r "$SCRIPT_DIR/../../.cp/systemd/logind.conf.d/" /etc/systemd/
    sudo cp -r "$SCRIPT_DIR/../../.cp/systemd/sleep.conf.d/" /etc/systemd/ 
    log_success "Lid management configured"
  fi
fi

log_success "Laptop tools installed and configured"
log_info "Run 'fwupdmgr update' to update firmware"

if [[ "$setup_fingerprint" == "true" ]]; then
  echo
  log_header "Fingerprint Enrollment"
  log_info "Starting fingerprint enrollment..."
  fprintd-enroll
  fprintd-verify
  
  if [[ -f "$SCRIPT_DIR/../../.cp/pam.d/system-local-login" ]]; then
    sudo cp -r "$SCRIPT_DIR/../../.cp/pam.d/system-local-login" /etc/pam.d/system-local-login
    sudo cp -r "$SCRIPT_DIR/../../.cp/pam.d/polkit-1" /etc/pam.d/polkit-1
    sudo cp -r "$SCRIPT_DIR/../../.cp/systemd/system/kill-fprintd.service" /etc/systemd/system/
    log_success "PAM configuration updated"
  fi
  
  log_success "Fingerprint setup complete"
fi
