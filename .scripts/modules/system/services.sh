#!/usr/bin/env bash

# Configures systemd services (Arch Linux laptop optimizations)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"
source "$DOTFILES_DIR/.scripts/lib/yaml.sh"

# Load platform-specific package manager
case "$PLATFORM" in
    linux)
        if [[ "$DISTRO" == "arch" ]]; then
            source "$DOTFILES_DIR/.scripts/platforms/arch/package-manager.sh"
        fi
        ;;
esac

# Process a single service from YAML
_process_service() {
    local name="$1"
    local package="$2"
    local enable="$3"
    local config_src="$4"
    local config_dest="$5"
    
    log_step "Setting up $name..."
    
    # Install package if specified
    if [[ -n "$package" && "$package" != "null" ]]; then
        if ! pkg_ensure "$package"; then
            log_error "Failed to install $package"
            return 1
        fi
    fi
    
    # Copy config if specified
    if [[ -n "$config_src" && "$config_src" != "null" ]]; then
        local src_path="$DOTFILES_DIR/$config_src"
        if [[ -f "$src_path" ]]; then
            log_info "Installing $name configuration..."
            run sudo cp "$src_path" "$config_dest"
        else
            log_warning "Config file not found: $src_path"
        fi
    fi
    
    # Enable service if specified
    if [[ "$enable" == "true" ]]; then
        run sudo systemctl enable --now "${name}.service" 2>/dev/null || \
        run sudo systemctl enable --now "$name" 2>/dev/null || \
        log_warning "Could not enable service: $name"
    fi
    
    log_success "$name configured"
}

# Configure laptop power management services
configure_laptop_services() {
    header "Laptop Power Management"
    
    if ! confirm "Configure laptop power management services?" true; then
        log_skip "Skipped laptop services"
        return 0
    fi
    
    # Process all services from YAML
    process_services "arch" "laptop" "_process_service"
    
    # Handle microcode (special case - just install, no service)
    local microcode_pkg=$(get_laptop_config "arch" "microcode" "package")
    if [[ -n "$microcode_pkg" && "$microcode_pkg" != "null" ]]; then
        log_step "Installing $microcode_pkg..."
        if pkg_ensure "$microcode_pkg"; then
            log_success "$microcode_pkg installed"
            log_warning "Regenerate initramfs after reboot: sudo mkinitcpio -P"
        fi
    fi
    
    # Handle firmware updates (timer instead of service)
    local firmware_pkg=$(get_laptop_config "arch" "firmware" "package")
    local firmware_timer=$(get_laptop_config "arch" "firmware" "timer")
    if [[ -n "$firmware_pkg" && "$firmware_pkg" != "null" ]]; then
        log_step "Setting up $firmware_pkg..."
        if pkg_ensure "$firmware_pkg"; then
            if [[ -n "$firmware_timer" && "$firmware_timer" != "null" ]]; then
                run sudo systemctl enable --now "$firmware_timer"
            fi
            log_success "$firmware_pkg configured"
            log_info "Check for firmware updates: fwupdmgr get-updates"
        fi
    fi
}

# Configure fingerprint reader
configure_fingerprint() {
    header "Fingerprint Reader"
    
    if ! confirm "Configure fingerprint reader?" false; then
        log_skip "Skipped fingerprint setup"
        return 0
    fi
    
    local fingerprint_pkg=$(get_laptop_config "arch" "fingerprint" "package")
    
    if [[ -z "$fingerprint_pkg" || "$fingerprint_pkg" == "null" ]]; then
        log_skip "No fingerprint configuration in YAML"
        return 0
    fi
    
    log_step "Installing $fingerprint_pkg..."
    if pkg_ensure "$fingerprint_pkg"; then
        # Install PAM configuration from YAML
        get_pam_files "arch" | while read -r line; do
            local src=$(echo "$line" | awk '{print $1}')
            local dest=$(echo "$line" | awk '{print $2}')
            
            if [[ -f "$DOTFILES_DIR/$src" ]]; then
                log_info "Installing PAM configuration: $(basename $dest)..."
                run sudo cp "$DOTFILES_DIR/$src" "$dest"
            else
                log_warning "PAM file not found: $src"
            fi
        done
        
        log_success "$fingerprint_pkg configured"
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
    
    local config_dir=$(get_laptop_config "arch" "logind" "config_dir")
    local dest_dir=$(get_laptop_config "arch" "logind" "dest_dir")
    
    if [[ -z "$config_dir" || "$config_dir" == "null" ]]; then
        log_skip "No logind configuration in YAML"
        return 0
    fi
    
    log_step "Installing logind configuration..."
    
    local src_path="$DOTFILES_DIR/$config_dir"
    if [[ -d "$src_path" ]]; then
        run sudo cp -r "$src_path" "$dest_dir"
        log_success "Logind configuration installed"
        log_info "Restart systemd-logind: sudo systemctl restart systemd-logind"
    else
        log_warning "Logind config directory not found: $src_path"
    fi
}

# Configure firewall
configure_firewall() {
    header "Firewall (UFW)"
    
    if ! confirm "Configure firewall?" true; then
        log_skip "Skipped firewall setup"
        return 0
    fi
    
    local fw_package=$(get_firewall_config "arch" "package")
    local fw_service=$(get_firewall_config "arch" "service")
    local fw_enable=$(get_firewall_config "arch" "enable")
    
    if [[ -z "$fw_package" || "$fw_package" == "null" ]]; then
        log_skip "No firewall configuration in YAML"
        return 0
    fi
    
    log_step "Setting up $fw_package..."
    if pkg_ensure "$fw_package"; then
        if [[ "$fw_enable" == "true" ]]; then
            run sudo systemctl enable --now "$fw_service"
        fi
        
        # Apply rules from YAML
        get_firewall_rules "arch" | while read -r rule; do
            if [[ -n "$rule" && "$rule" != "null" ]]; then
                log_info "Applying rule: $rule"
                run sudo ufw $rule
            fi
        done
        
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
