#!/usr/bin/env bash

# Bootstrap script for fresh system installation
# Usage: sh ./bootstrap.sh <arch|darwin>

set -e

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

print_usage() {
  echo "Usage: $0 <arch|darwin>"
  echo ""
  echo "Bootstrap a fresh system installation"
  echo ""
  echo "Arguments:"
  echo "  arch    - Bootstrap Arch Linux system"
  echo "  darwin  - Bootstrap macOS (Darwin) system"
  exit 1
}

print_header() {
  echo -e "${BLUE}================================================${NC}"
  echo -e "${BLUE}  Dotfiles Bootstrap${NC}"
  echo -e "${BLUE}================================================${NC}"
  echo ""
}

run_scripts() {
  local system="$1"
  local scripts_dir=".scripts/$system"
  
  if [[ ! -d "$scripts_dir" ]]; then
    echo -e "${RED}Error: Scripts directory not found: $scripts_dir${NC}" >&2
    exit 1
  fi
  
  # Find all .sh files and sort them
  local scripts=()
  while IFS= read -r -d '' script; do
    scripts+=("$script")
  done < <(find "$scripts_dir" -maxdepth 1 -name "*.sh" -type f -print0 | sort -z)
  
  if [[ ${#scripts[@]} -eq 0 ]]; then
    echo -e "${RED}Error: No scripts found in $scripts_dir${NC}" >&2
    exit 1
  fi
  
  echo -e "${BLUE}Found ${#scripts[@]} setup script(s)${NC}"
  echo ""
  
  # Execute each script in order
  for script in "${scripts[@]}"; do
    local script_name=$(basename "$script")
    echo -e "${BLUE}▶ Running: $script_name${NC}"
    echo ""
    
    if bash "$script"; then
      echo ""
      echo -e "${GREEN}✓ $script_name completed${NC}"
      echo ""
    else
      echo ""
      echo -e "${RED}✗ $script_name failed${NC}" >&2
      exit 1
    fi
  done
}

main() {
  # Check arguments
  if [[ $# -ne 1 ]]; then
    print_usage
  fi
  
  local system="$1"
  
  # Validate system argument
  if [[ "$system" != "arch" && "$system" != "darwin" ]]; then
    echo -e "${RED}Error: Invalid system '$system'${NC}" >&2
    echo ""
    print_usage
  fi
  
  print_header
  
  echo -e "${BLUE}System: $system${NC}"
  echo ""
  
  # Run the setup scripts
  run_scripts "$system"
  
  echo ""
  echo -e "${GREEN}================================================${NC}"
  echo -e "${GREEN}  Bootstrap Complete!${NC}"
  echo -e "${GREEN}================================================${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your shell or run: exec zsh"
  echo "  2. Open tmux and press Ctrl+A + I to install plugins"
  echo "  3. Run 'nvim' to let plugins install automatically"
  echo ""
}

main "$@"
