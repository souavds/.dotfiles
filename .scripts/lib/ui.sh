#!/usr/bin/env bash

# UI utilities using shell built-ins only

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

# Confirm action
confirm() {
    local prompt="$1"
    local default="${2:-false}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would prompt: $prompt"
        return 0
    fi
    
    if [[ "$default" == "true" ]]; then
        read -p "$prompt (Y/n) " -n 1 -r
        echo
        [[ -z "$REPLY" ]] || [[ $REPLY =~ ^[Yy]$ ]]
    else
        read -p "$prompt (y/N) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Choose from list (multi-select)
choose() {
    local prompt="$1"
    shift
    local options=("$@")
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would prompt: $prompt"
        echo "${options[@]}"
        return 0
    fi
    
    log_info "$prompt"
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[$i]}"
    done
    echo "Enter numbers separated by space (e.g., 1 2 3):"
    read -r selection
    for num in $selection; do
        echo "${options[$((num-1))]}"
    done
}

# Choose single item
choose_one() {
    local prompt="$1"
    shift
    local options=("$@")
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would prompt: $prompt"
        echo "${options[0]}"
        return 0
    fi
    
    log_info "$prompt"
    select opt in "${options[@]}"; do
        echo "$opt"
        break
    done
}

# Input text
input() {
    local prompt="$1"
    local default="${2:-}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would prompt: $prompt"
        echo "$default"
        return 0
    fi
    
    read -p "$prompt [$default]: " -r input_value
    echo "${input_value:-$default}"
}

# Display spinner with message
spin() {
    local message="$1"
    shift
    local cmd="$@"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] $message"
        return 0
    fi
    
    log_info "$message"
    eval "$cmd"
}

# Format output (simplified without gum)
format() {
    shift
    local text="$*"
    echo "$text"
}

# Display styled header
header() {
    echo ""
    echo "========================================"
    echo "  $*"
    echo "========================================"
    echo ""
}

# Display table
table() {
    local -n data=$1
    printf "%s\n" "${data[@]}"
}
