#!/usr/bin/env bash

# Configures systemd services (Arch Linux laptop optimizations)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/lib/core.sh"
source "$DOTFILES_DIR/lib/ui.sh"

# Load platform-specific package manager
case "$PLATFORM" in
    linux)
        if [[ "$DISTRO" == "arch" ]]; then
            source "$DOTFILES_DIR/platforms/arch/package-manager.sh"
        fi
        ;;
esac

# Configure laptop power management services
configure_laptop_services() {
    header "Laptop Power Management"
    
    if ! confirm "Configure laptop power management services?" true; then
        log_skip "Skipped laptop services"
        return 0
    fi
    
    # Thermald - Intel thermal management
    log_step "Setting up thermald..."
    if pkg_ensure thermald; then
        run sudo systemctl enable --now thermald.service
        log_success "thermald configured"
    fi
    
    # ACPI daemon
    log_step "Setting up acpid..."
    if pkg_ensure acpi; then
        run sudo systemctl enable --now acpid.service
        log_success "acpid configured"
    fi
    
    # auto-cpufreq - CPU frequency optimization
    log_step "Setting up auto-cpufreq..."
    if pkg_ensure auto-cpufreq; then
        # Copy config if it exists
        if [[ -f "$DOTFILES_DIR/.cp/auto-cpufreq.conf" ]]; then
            log_info "Installing auto-cpufreq configuration..."
            run sudo cp "$DOTFILES_DIR/.cp/auto-cpufreq.conf" /etc/auto-cpufreq.conf
        fi
        run sudo systemctl enable --now auto-cpufreq
        log_success "auto-cpufreq configured"
    fi
    
    # Intel microcode
    log_step "Installing Intel microcode..."
    if pkg_ensure intel-ucode; then
        log_success "Intel microcode installed"
        log_warning "Regenerate initramfs after reboot: sudo mkinitcpio -P"
    fi
    
    # Firmware updates
    log_step "Setting up fwupd..."
    if pkg_ensure fwupd; then
        run sudo systemctl enable --now fwupd-refresh.timer
        log_success "fwupd configured"
        log_info "Check for firmware updates: fwupdmgr get-updates"
    fi
}

# Configure fingerprint reader
configure_fingerprint() {
    header "Fingerprint Reader"
    
    if ! confirm "Configure fingerprint reader?" false; then
        log_skip "Skipped fingerprint setup"
        return 0
    fi
    
    log_step "Installing fprintd..."
    if pkg_ensure fprintd; then
        # Install PAM configuration
        if [[ -f "$DOTFILES_DIR/.cp/pam.d/system-local-login" ]]; then
            log_info "Installing PAM configuration for local login..."
            run sudo cp "$DOTFILES_DIR/.cp/pam.d/system-local-login" /etc/pam.d/system-local-login
        fi
        
        if [[ -f "$DOTFILES_DIR/.cp/pam.d/polkit-1" ]]; then
            log_info "Installing PAM configuration for polkit..."
            run sudo cp "$DOTFILES_DIR/.cp/pam.d/polkit-1" /etc/pam.d/polkit-1
        fi
        
        log_success "fprintd configured"
        log_warning "Run 'fprintd-enroll' manually to enroll your fingerprint"
        log_warning "Run 'fprintd-verify' to test fingerprint recognition"
    fi
}

# Configure lid switch behavior
configure_logind() {
    header "Lid Switch Configuration"
    
    if ! confirm "Configure lid switch behavior?" true; then
        log_skip "Skipped logind configuration"
        return 0
    fi
    
    log_step "Installing logind configuration..."
    
    if [[ -d "$DOTFILES_DIR/.cp/systemd/logind.conf.d" ]]; then
        run sudo cp -r "$DOTFILES_DIR/.cp/systemd/logind.conf.d" /etc/systemd/
        log_success "Logind configuration installed"
        log_info "Restart systemd-logind: sudo systemctl restart systemd-logind"
    else
        log_warning "Logind config directory not found: $DOTFILES_DIR/.cp/systemd/logind.conf.d"
    fi
}

# Configure firewall
configure_firewall() {
    header "Firewall (UFW)"
    
    if ! confirm "Configure firewall?" true; then
        log_skip "Skipped firewall setup"
        return 0
    fi
    
    log_step "Setting up UFW firewall..."
    if pkg_ensure ufw; then
        run sudo systemctl enable --now ufw
        run sudo ufw default deny incoming
        run sudo ufw default allow outgoing
        run sudo ufw --force enable
        log_success "Firewall configured and enabled"
    fi
}

# Main installation
main() {
    header "System Services Configuration"
    
    case "$PLATFORM" in
        linux)
            if [[ "$DISTRO" == "arch" ]]; then
                configure_laptop_services
                configure_fingerprint
                configure_logind
                configure_firewall
            else
                log_error "Unsupported Linux distribution: $DISTRO"
                return 1
            fi
            ;;
        darwin)
            log_info "macOS doesn't use systemd services"
            log_info "macOS-specific services can be added here in the future"
            ;;
        *)
            log_error "Unsupported platform: $PLATFORM"
            return 1
            ;;
    esac
    
    log_success "System services configuration complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
