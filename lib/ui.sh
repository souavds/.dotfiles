#!/usr/bin/env bash

# UI utilities using gum for interactive prompts
# Provides consistent user interaction across all scripts

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

# Check if gum is available
if ! command_exists gum; then
    log_warning "gum not installed, using fallback prompts"
    GUM_AVAILABLE=false
else
    GUM_AVAILABLE=true
fi

# Confirm action
confirm() {
    local prompt="$1"
    local default="${2:-false}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would prompt: $prompt"
        return 0
    fi
    
    if [[ "$GUM_AVAILABLE" == "true" ]]; then
        if [[ "$default" == "true" ]]; then
            gum confirm "$prompt" --default=true
        else
            gum confirm "$prompt"
        fi
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
    
    if [[ "$GUM_AVAILABLE" == "true" ]]; then
        printf "%s\n" "${options[@]}" | gum choose --no-limit --header "$prompt"
    else
        log_info "$prompt"
        for i in "${!options[@]}"; do
            echo "$((i+1)). ${options[$i]}"
        done
        echo "Enter numbers separated by space (e.g., 1 2 3):"
        read -r selection
        for num in $selection; do
            echo "${options[$((num-1))]}"
        done
    fi
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
    
    if [[ "$GUM_AVAILABLE" == "true" ]]; then
        printf "%s\n" "${options[@]}" | gum choose --header "$prompt"
    else
        log_info "$prompt"
        select opt in "${options[@]}"; do
            echo "$opt"
            break
        done
    fi
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
    
    if [[ "$GUM_AVAILABLE" == "true" ]]; then
        if [[ -n "$default" ]]; then
            gum input --placeholder "$default" --prompt "$prompt: "
        else
            gum input --prompt "$prompt: "
        fi
    else
        read -p "$prompt [$default]: " -r input
        echo "${input:-$default}"
    fi
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
    
    if [[ "$GUM_AVAILABLE" == "true" ]]; then
        gum spin --spinner dot --title "$message" -- bash -c "$cmd"
    else
        log_info "$message"
        eval "$cmd"
    fi
}

# Format output
format() {
    local style="$1"
    shift
    local text="$*"
    
    if [[ "$GUM_AVAILABLE" == "true" ]]; then
        gum style --foreground "$style" "$text"
    else
        echo "$text"
    fi
}

# Display styled header
header() {
    if [[ "$GUM_AVAILABLE" == "true" ]]; then
        gum style \
            --border double \
            --padding "1 2" \
            --border-foreground 212 \
            "$*"
    else
        echo "================================"
        echo "$*"
        echo "================================"
    fi
}

# Display table
table() {
    local -n data=$1
    
    if [[ "$GUM_AVAILABLE" == "true" ]]; then
        gum table "${data[@]}"
    else
        printf "%s\n" "${data[@]}"
    fi
}
