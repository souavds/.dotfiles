#!/usr/bin/env bash

# YAML parsing utilities using yq

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

# Check if yq is available and show helpful error if not
check_yq() {
    if ! command_exists yq; then
        log_error "yq is required for parsing YAML configuration files"
        log_info "Install it with: sudo pacman -S go-yq (Arch) or brew install yq (macOS)"
        log_info "Or run: just bootstrap"
        return 1
    fi
}

# Parse YAML and extract scalar values
# Usage: yaml_get <file> <path>
# Example: yaml_get "config/packages.yml" "common.essential"
yaml_get() {
    local file="$1"
    local key="$2"
    
    if [[ ! -f "$file" ]]; then
        log_error "YAML file not found: $file"
        return 1
    fi
    
    check_yq || return 1
    
    yq eval "$key" "$file" 2>/dev/null || true
}

# Get array from YAML
# Usage: yaml_array <file> <path>
# Example: yaml_array "config/packages.yml" "common.essential"
yaml_array() {
    local file="$1"
    local path="$2"
    
    check_yq || return 1
    
    yq eval "${path}[]" "$file" 2>/dev/null | grep -v '^null$' || true
}

# Check if YAML key exists
yaml_has() {
    local file="$1"
    local key="$2"
    
    check_yq || return 1
    
    yq eval "has(\"$key\")" "$file" 2>/dev/null | grep -q "true"
}

# Get packages for a specific category and platform
get_packages() {
    local category="$1"
    local platform="${2:-common}"
    local yaml_file="$CONFIG_DIR/packages.yml"
    
    if [[ "$platform" == "common" ]]; then
        yaml_array "$yaml_file" "common.${category}"
    else
        yaml_array "$yaml_file" "${platform}.${category}"
    fi
}

# Get all packages for a category (common + platform)
get_all_packages() {
    local category="$1"
    local platform="${DISTRO:-$PLATFORM}"
    
    {
        get_packages "$category" "common"
        get_packages "$category" "$platform"
    } | sort -u
}

# ========================================
# Services YAML Helpers
# ========================================

# Get service count for a platform/device
get_service_count() {
    local platform="$1"
    local device="${2:-}"
    local yaml_file="$CONFIG_DIR/services.yml"
    
    if [[ -n "$device" ]]; then
        yaml_get "$yaml_file" "${platform}.${device}.services | length"
    else
        yaml_get "$yaml_file" "${platform}.services | length"
    fi
}

# Get list of service names
get_service_names() {
    local platform="$1"
    local device="${2:-}"
    local yaml_file="$CONFIG_DIR/services.yml"
    
    if [[ -n "$device" ]]; then
        yaml_get "$yaml_file" "${platform}.${device}.services[].name"
    else
        yaml_get "$yaml_file" "${platform}.services[].name"
    fi
}

# Get service field value
get_service_field() {
    local platform="$1"
    local device="$2"
    local index="$3"
    local field="$4"
    local yaml_file="$CONFIG_DIR/services.yml"
    
    if [[ -n "$device" ]]; then
        yaml_get "$yaml_file" "${platform}.${device}.services[$index].$field"
    else
        yaml_get "$yaml_file" "${platform}.services[$index].$field"
    fi
}

# Process each service in services.yml
# Usage: process_services <platform> <device> <callback_function>
# Callback receives: name package enable config_src config_dest
process_services() {
    local platform="$1"
    local device="$2"
    local callback="$3"
    local yaml_file="$CONFIG_DIR/services.yml"
    
    check_yq || return 1
    
    # Get count of services
    local count=$(yq eval ".${platform}.${device}.services | length" "$yaml_file" 2>/dev/null || echo "0")
    
    if [[ "$count" == "0" || "$count" == "null" ]]; then
        return 0
    fi
    
    # Process each service
    for ((i=0; i<count; i++)); do
        local name=$(get_service_field "$platform" "$device" "$i" "name")
        local package=$(get_service_field "$platform" "$device" "$i" "package")
        local enable=$(get_service_field "$platform" "$device" "$i" "enable")
        local config_src=$(get_service_field "$platform" "$device" "$i" "config_src")
        local config_dest=$(get_service_field "$platform" "$device" "$i" "config_dest")
        
        # Skip if name is empty or null
        [[ -z "$name" || "$name" == "null" ]] && continue
        
        # Call the callback with service data
        "$callback" "$name" "$package" "$enable" "$config_src" "$config_dest"
    done
}

# Get firewall configuration
get_firewall_config() {
    local platform="$1"
    local field="$2"
    local yaml_file="$CONFIG_DIR/services.yml"
    
    yaml_get "$yaml_file" "${platform}.firewall.${field}"
}

# Get firewall rules
get_firewall_rules() {
    local platform="$1"
    local yaml_file="$CONFIG_DIR/services.yml"
    
    yaml_get "$yaml_file" "${platform}.firewall.rules[]"
}

# Get laptop-specific configs
get_laptop_config() {
    local platform="$1"
    local section="$2"
    local field="$3"
    local yaml_file="$CONFIG_DIR/services.yml"
    
    yaml_get "$yaml_file" "${platform}.laptop.${section}.${field}"
}

# Get PAM files configuration
get_pam_files() {
    local platform="$1"
    local yaml_file="$CONFIG_DIR/services.yml"
    
    check_yq || return 1
    
    yq eval ".${platform}.laptop.fingerprint.pam_files[] | (.src + \" \" + .dest)" "$yaml_file" 2>/dev/null
}
