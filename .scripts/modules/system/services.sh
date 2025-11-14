#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/.scripts/lib/core.sh"
source "$DOTFILES_DIR/.scripts/lib/ui.sh"
source "$DOTFILES_DIR/.scripts/lib/yaml.sh"
source "$DOTFILES_DIR/.scripts/lib/pkg.sh"

_process_service() {
    local name="$1"
    local package="$2"
    local enable="$3"
    local config_src="$4"
    local config_dest="$5"

    log_step "Setting up $name..."

    if [[ -n "$package" && "$package" != "null" ]]; then
        if ! pkg_ensure "$package"; then
            log_error "Failed to install $package"
            return 1
        fi
    fi

    if [[ -n "$config_src" && "$config_src" != "null" ]]; then
        local src_path="$DOTFILES_DIR/$config_src"
        if [[ -f "$src_path" ]]; then
            log_info "Installing $name configuration..."
            run sudo cp "$src_path" "$config_dest"
        else
            log_warning "Config file not found: $src_path"
        fi
    fi

    if [[ "$enable" == "true" ]]; then
        log_info "Enabling $name service..."
        run sudo systemctl enable --now "$name"
    fi

    log_success "$name setup complete"
}

setup_laptop_services() {
    header "Laptop Services"

    log_info "Configuring laptop-specific services..."

    process_services "$PLATFORM" "laptop" _process_service

    log_success "Laptop services configured"
}

setup_firmware() {
    header "Firmware Updates"

    local fw_package=$(get_laptop_config "$PLATFORM" "firmware" "package")
    local fw_timer=$(get_laptop_config "$PLATFORM" "firmware" "timer")

    if [[ -n "$fw_package" && "$fw_package" != "null" ]]; then
        pkg_ensure "$fw_package"

        if [[ -n "$fw_timer" && "$fw_timer" != "null" ]]; then
            log_info "Enabling firmware update timer..."
            run sudo systemctl enable --now "$fw_timer"
        fi

        log_info "Checking for firmware updates..."
        run fwupdmgr get-updates || log_info "No firmware updates available"

        log_success "Firmware management configured"
    fi
}

setup_microcode() {
    header "CPU Microcode"

    local mc_package=$(get_laptop_config "$PLATFORM" "microcode" "package")

    if [[ -n "$mc_package" && "$mc_package" != "null" ]]; then
        pkg_ensure "$mc_package"
        log_success "Microcode installed"
        log_info "Microcode will be loaded on next boot"
    fi
}

setup_fingerprint() {
    header "Fingerprint Authentication"

    local fp_package=$(get_laptop_config "$PLATFORM" "fingerprint" "package")
    local interactive=$(get_laptop_config "$PLATFORM" "fingerprint" "interactive_setup")

    if [[ -n "$fp_package" && "$fp_package" != "null" ]]; then
        pkg_ensure "$fp_package"

        log_info "Configuring PAM for fingerprint authentication..."
        while IFS= read -r pam_config; do
            [[ -z "$pam_config" ]] && continue
            local src=$(echo "$pam_config" | awk '{print $1}')
            local dest=$(echo "$pam_config" | awk '{print $2}')

            if [[ -f "$DOTFILES_DIR/$src" ]]; then
                log_info "Installing PAM config: $dest"
                run sudo cp "$DOTFILES_DIR/$src" "$dest"
            fi
        done < <(get_pam_files "$PLATFORM")

        if [[ "$interactive" == "true" ]]; then
            log_info "Fingerprint setup requires manual enrollment"
            log_info "After installation, run:"
            log_info "  fprintd-enroll    # Enroll fingerprint"
            log_info "  fprintd-verify    # Verify fingerprint"
        fi

        log_success "Fingerprint authentication configured"
    fi
}

setup_logind() {
    header "Logind Configuration"

    local config_dir=$(get_laptop_config "$PLATFORM" "logind" "config_dir")
    local dest_dir=$(get_laptop_config "$PLATFORM" "logind" "dest_dir")

    if [[ -n "$config_dir" && "$config_dir" != "null" ]]; then
        if [[ -d "$DOTFILES_DIR/$config_dir" ]]; then
            log_info "Installing logind configuration..."
            run sudo cp -r "$DOTFILES_DIR/$config_dir" "$dest_dir"
            log_success "Logind configured (lid behavior, power management)"
        fi
    fi
}

setup_firewall() {
    header "Firewall"

    local fw_package=$(get_firewall_config "$PLATFORM" "package")
    local fw_service=$(get_firewall_config "$PLATFORM" "service")
    local fw_enable=$(get_firewall_config "$PLATFORM" "enable")

    if [[ -n "$fw_package" && "$fw_package" != "null" ]]; then
        pkg_ensure "$fw_package"

        if [[ "$fw_enable" == "true" ]]; then
            log_info "Enabling and configuring firewall..."

            run sudo systemctl enable --now "$fw_service"

            while IFS= read -r rule; do
                [[ -z "$rule" ]] && continue
                log_info "Applying rule: $rule"
                run sudo ufw $rule
            done < <(get_firewall_rules "$PLATFORM")

            run sudo ufw enable

            log_success "Firewall configured and enabled"
        fi
    fi
}

main() {
    header "System Services Configuration"

    if [[ "$PLATFORM" != "linux" ]] || [[ "$DISTRO" != "arch" ]]; then
        log_info "Service configuration only supported on Arch Linux"
        return 0
    fi

    if ! confirm "Configure laptop-specific services?" false; then
        log_skip "Skipped laptop services"
        return 0
    fi

    setup_laptop_services
    setup_firmware
    setup_microcode
    setup_fingerprint
    setup_logind
    setup_firewall

    log_success "System services configuration complete!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
