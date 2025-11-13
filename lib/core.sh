#!/usr/bin/env bash

# Core utilities for dotfiles installation
# Provides logging, error handling, and platform detection

set -euo pipefail

# Colors for output (only set if not already defined)
if [[ -z "${RED:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly MAGENTA='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly NC='\033[0m' # No Color
fi

# Dotfiles directory
export DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export BACKUP_DIR="${BACKUP_DIR:-$DOTFILES_DIR/.backups}"
export CONFIG_DIR="${CONFIG_DIR:-$DOTFILES_DIR/config}"
export LOG_FILE="${LOG_FILE:-$DOTFILES_DIR/install.log}"

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "darwin" ;;
        *)          echo "unknown" ;;
    esac
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

export PLATFORM=$(detect_platform)
export DISTRO=$(detect_distro)

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
    log "INFO" "$*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
    log "SUCCESS" "$*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
    log "WARNING" "$*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    log "ERROR" "$*"
}

log_step() {
    echo -e "${MAGENTA}[STEP]${NC} $*"
    log "STEP" "$*"
}

log_skip() {
    echo -e "${CYAN}[SKIP]${NC} $*"
    log "SKIP" "$*"
}

# Error handling
error() {
    log_error "$1"
    exit "${2:-1}"
}

# Command validation
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_command() {
    if ! command_exists "$1"; then
        error "$1 is required but not found. Please install it first."
    fi
}

# File operations
ensure_dir() {
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
        log_info "Created directory: $1"
    fi
}

file_exists() {
    [[ -f "$1" ]] || [[ -L "$1" ]]
}

is_symlink() {
    [[ -L "$1" ]]
}

# Dry run support
DRY_RUN="${DRY_RUN:-false}"

run() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would execute: $*"
        return 0
    fi
    "$@"
}

# Progress indicator
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Initialize logging
ensure_dir "$(dirname "$LOG_FILE")"
log_info "=== Dotfiles installation started ==="
log_info "Platform: $PLATFORM"
log_info "Distro: $DISTRO"
log_info "Dotfiles dir: $DOTFILES_DIR"
