#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${RED:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly MAGENTA='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly NC='\033[0m'
fi

# DOTFILES_DIR should be set by calling script before sourcing this file
# If not set, try to detect it (will be .scripts/ parent directory)
if [[ -z "${DOTFILES_DIR:-}" ]]; then
    # Go up two levels from .scripts/lib/ to get to dotfiles root
    export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

export BACKUP_DIR="${BACKUP_DIR:-$DOTFILES_DIR/.backups}"
export CONFIG_DIR="${CONFIG_DIR:-$DOTFILES_DIR/config}"
export LOG_FILE="${LOG_FILE:-$DOTFILES_DIR/install.log}"
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

error() {
    log_error "$1"
    exit "${2:-1}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_command() {
    if ! command_exists "$1"; then
        error "$1 is required but not found. Please install it first."
    fi
}

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

DRY_RUN="${DRY_RUN:-false}"

run() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would execute: $*"
        return 0
    fi
    "$@"
}

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

# Initialize log directory (but don't log yet - let scripts control logging)
ensure_dir "$(dirname "$LOG_FILE")"

# Optional: Scripts can call this function to log startup info
log_startup_info() {
    log_info "=== Dotfiles installation started ==="
    log_info "Platform: $PLATFORM"
    log_info "Distro: $DISTRO"
    log_info "Dotfiles dir: $DOTFILES_DIR"
}
