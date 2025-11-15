#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Installing Essential Packages"

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add brew to PATH
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  
  log_success "Homebrew installed"
fi

# Update brew
log_info "Updating Homebrew..."
brew update

# Read essential packages into array
packages=()
while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  packages+=("$pkg")
done < "$SCRIPT_DIR/../packages/darwin/essential"

# Install all essential packages at once
log_info "Installing essential packages..."
brew install "${packages[@]}"

log_success "Essential packages installed"
