#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"
source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"

# Validate platform is supported
validate_platform() {
  log_step "Validating platform..."

  case "$PLATFORM" in
    linux | darwin)
      log_success "Platform supported: $PLATFORM"
      return 0
      ;;
    *)
      error "Unsupported platform: $PLATFORM"
      ;;
  esac
}

# Validate required commands exist
validate_commands() {
  log_step "Validating required commands..."

  local required_commands=(
    "bash"
    "git"
    "stow"
  )

  local missing=()

  for cmd in "${required_commands[@]}"; do
    if ! command_exists "$cmd"; then
      missing+=("$cmd")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    log_error "Missing required commands: ${missing[*]}"
    log_info "Please install them first:"

    case "$PLATFORM" in
      linux)
        if [[ "$DISTRO" == "arch" ]]; then
          log_info "  sudo pacman -S ${missing[*]}"
        fi
        ;;
      darwin)
        log_info "  brew install ${missing[*]}"
        ;;
    esac

    return 1
  fi

  log_success "All required commands available"
  return 0
}

# Validate we're in dotfiles directory
validate_dotfiles_dir() {
  log_step "Validating dotfiles directory..."

  if [[ ! -d "$DOTFILES_DIR/.config" ]]; then
    error "Not in dotfiles directory. Expected .config/ to exist in $DOTFILES_DIR"
  fi

  log_success "Dotfiles directory validated: $DOTFILES_DIR"
}

# Check if running with sudo (should not be)
validate_not_root() {
  log_step "Checking user permissions..."

  if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root. Run as regular user."
  fi

  log_success "Running as regular user"
}

# Check sudo access
validate_sudo_access() {
  log_step "Validating sudo access..."

  if ! sudo -n true 2>/dev/null; then
    log_info "Sudo access required for system configuration"
    if ! sudo true; then
      error "Failed to obtain sudo access"
    fi
  fi

  log_success "Sudo access available"
}

# Validate YAML parser is available
validate_yaml_parser() {
  log_step "Validating YAML parser..."

  if command_exists yq; then
    log_success "yq is available"
    return 0
  fi

  log_warning "No YAML parser found (yq recommended)"
  log_info "Installing yq is recommended for better YAML support"

  return 0
}

# Check disk space
validate_disk_space() {
  log_step "Checking disk space..."

  local available
  available=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
  local required=5

  if [[ $available -lt $required ]]; then
    log_warning "Low disk space: ${available}GB available, ${required}GB recommended"
  else
    log_success "Sufficient disk space: ${available}GB available"
  fi
}

# Check internet connectivity
validate_internet() {
  log_step "Checking internet connectivity..."

  if ping -c 1 8.8.8.8 &>/dev/null || ping -c 1 1.1.1.1 &>/dev/null; then
    log_success "Internet connection available"
    return 0
  else
    log_warning "No internet connection detected"
    return 1
  fi
}

# Run all validations
validate_all() {
  header "Pre-flight Checks"

  local checks=(
    validate_platform
    validate_not_root
    validate_dotfiles_dir
    validate_commands
    validate_yaml_parser
    validate_disk_space
    validate_internet
  )

  local failed=0

  for check in "${checks[@]}"; do
    if ! $check; then
      ((failed++))
    fi
  done

  echo

  if [[ $failed -gt 0 ]]; then
    log_error "$failed validation(s) failed"
    return 1
  else
    log_success "All validations passed"
    return 0
  fi
}
