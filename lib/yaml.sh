#!/usr/bin/env bash

# YAML parsing utilities
# Provides simple YAML reading with fallback methods

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
    
    # Try yq first (best YAML parser)
    if command_exists yq; then
        yq eval "$key" "$file" 2>/dev/null || true
        return 0
    fi
    
    # Try gum (has YAML support)
    if command_exists gum; then
        # gum doesn't have direct YAML query, fall through to grep
        :
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
        # Simple grep-based extraction for arrays
        local section=$(echo "$path" | tr '.' ' ' | awk '{print $NF}')
        grep -A 100 "^${section}:" "$file" | sed -n '/^[^ #]/q;p' | grep -E '^\s*-\s+' | sed 's/^\s*-\s*//' || true
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
