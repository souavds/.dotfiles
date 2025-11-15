#!/usr/bin/env bash

# TUI Helper Library
# Simple logging and user interaction functions

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Log functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $*"
}

log_step() {
  echo
  echo -e "${BLUE}==>${NC} $*"
}

log_header() {
  echo
  echo -e "${BLUE}================================================${NC}"
  echo -e "${BLUE}  $*${NC}"
  echo -e "${BLUE}================================================${NC}"
  echo
}

# User confirmation
confirm() {
  local prompt="$1"
  local response
  
  while true; do
    read -r -p "$prompt [y/N] " response
    case "$response" in
      [yY][eE][sS]|[yY]) 
        return 0
        ;;
      [nN][oO]|[nN]|"")
        return 1
        ;;
      *)
        echo "Please answer yes or no."
        ;;
    esac
  done
}

# Read user input with default
read_input() {
  local prompt="$1"
  local default="$2"
  local response
  
  read -r -p "$prompt [$default]: " response
  echo "${response:-$default}"
}
