#!/usr/bin/env bash

# YAML parsing utilities

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

# Parse YAML and extract values
# Falls back to grep/sed if yq not available
yaml_get() {
    local file="$1"
    local key="$2"
    
    if [[ ! -f "$file" ]]; then
        log_error "YAML file not found: $file"
        return 1
    fi
    
    # yq first (best YAML parser)
    if command_exists yq; then
        yq eval "$key" "$file" 2>/dev/null || true
        return 0
    fi
    
    # Fallback to grep/sed (limited, but works for simple cases)
    # This won't handle complex YAML, but good enough for our use case
    local result=$(grep -A 100 "$key:" "$file" | sed -n '/^[^ ]/q;p' | grep -E '^\s*-\s+' | sed 's/^\s*-\s*//' | grep -v ':' || true)
    
    if [[ -n "$result" ]]; then
        echo "$result"
    fi
}

# Get array from YAML
yaml_array() {
    local file="$1"
    local path="$2"
    
    if command_exists yq; then
        yq eval "${path}[]" "$file" 2>/dev/null | grep -v '^null$' || true
    else
        # Fallback grep-based extraction for arrays
        # Handle paths like "common.essential" or "arch.packages"
        local parts=(${path//./ })
        local section="${parts[-1]}"
        
        # For nested paths, try to find the right section
        if [[ ${#parts[@]} -eq 2 ]]; then
            local parent="${parts[0]}"
            # Extract items from parent.section using awk
            awk -v parent="^${parent}:" -v section="^  ${section}:" '
                $0 ~ parent {in_parent=1; next}
                in_parent && /^[^ ]/ {exit}
                in_parent && $0 ~ section {in_section=1; next}
                in_section && /^  [^ ]/ && $0 !~ section {exit}
                in_section && /^\s*-\s+/ {sub(/^\s*-\s*/, ""); print}
            ' "$file"
        else
            # Simple single-level lookup
            grep -A 100 "^${section}:" "$file" | sed -n '/^[^ #]/q;p' | grep -E '^\s*-\s+' | sed 's/^\s*-\s*//' || true
        fi
    fi
}

# Check if YAML key exists
yaml_has() {
    local file="$1"
    local key="$2"
    
    if command_exists yq; then
        yq eval "has(\"$key\")" "$file" 2>/dev/null | grep -q "true"
    else
        grep -q "^${key}:" "$file"
    fi
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
    
    # Get count of services
    local count=0
    if command_exists yq; then
        count=$(yq eval ".${platform}.${device}.services | length" "$yaml_file" 2>/dev/null || echo "0")
    fi
    
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
    
    if command_exists yq; then
        yq eval ".${platform}.laptop.fingerprint.pam_files[] | (.src + \" \" + .dest)" "$yaml_file" 2>/dev/null
    fi
}
