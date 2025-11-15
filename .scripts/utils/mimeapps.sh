#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.scripts/lib/tui.sh"

log_header "Setup Mimeapps"

if [[ ! -f "$SCRIPT_DIR/.templates/mimeapps.list.template" ]]; then
  log_error "Template not found: .templates/mimeapps.list.template"
  exit 1
fi

log_info "Generating mimeapps.list..."

envsubst < "$SCRIPT_DIR/.templates/mimeapps.list.template" > "$SCRIPT_DIR/.config/mimeapps.list"

log_success "mimeapps.list created at .config/mimeapps.list"
log_info "Current BROWSER: ${BROWSER:-not set}"

if [[ -z "$BROWSER" ]]; then
  log_warn "BROWSER environment variable is not set"
  log_info "Set it in your shell config (e.g., export BROWSER=firefox.desktop)"
fi
