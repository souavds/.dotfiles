#!/usr/bin/env bash

# Main installation script
# Entry point for dotfiles installation

set -euo pipefail

# Get dotfiles directory
export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core libraries
source "$DOTFILES_DIR/lib/core.sh"
source "$DOTFILES_DIR/lib/ui.sh"
source "$DOTFILES_DIR/lib/validation.sh"
source "$DOTFILES_DIR/lib/backup.sh"

# Parse arguments
TASK="full"
SKIP_VALIDATION=false

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Dotfiles installation script

OPTIONS:
    -h, --help          Show this help message
    -t, --task TASK     Installation task: full, minimal, dev (default: full)
    -d, --dry-run       Preview changes without applying
    -s, --skip-validation    Skip pre-flight checks
    -b, --backup NAME   Create backup before installing
    -v, --verbose       Verbose output

TASKS:
    full       Full installation (packages + languages + dotfiles + services)
    minimal    Just dotfiles (no packages)
    dev        Development environment (packages + languages + dotfiles)

EXAMPLES:
    # Full installation
    $0

    # Minimal installation (dotfiles only)
    $0 --task minimal

    # Dry run to preview changes
    $0 --dry-run

    # Use Just for more control
    just install-minimal
    just install-dev

EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -t|--task)
            TASK="$2"
            shift 2
            ;;
        -d|--dry-run)
            export DRY_RUN=true
            shift
            ;;
        -s|--skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        -b|--backup)
            backup_create "$2"
            shift 2
            ;;
        -v|--verbose)
            set -x
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main installation flow
main() {
    header "Dotfiles Installation"
    
    log_info "Task: $TASK"
    log_info "Platform: $PLATFORM ($DISTRO)"
    log_info "Dry run: ${DRY_RUN:-false}"
    echo
    
    # Validation
    if [[ "$SKIP_VALIDATION" != "true" ]]; then
        if ! validate_all; then
            error "Pre-flight checks failed"
        fi
        echo
    fi
    
    # Confirm before proceeding
    if [[ "$DRY_RUN" != "true" ]]; then
        if ! confirm "Proceed with installation?" true; then
            log_info "Installation cancelled"
            exit 0
        fi
        echo
    fi
    
    # Create backup before making changes
    if [[ "$DRY_RUN" != "true" ]]; then
        backup_create "pre-install-$(date +%Y%m%d-%H%M%S)"
        echo
    fi
    
    # Execute based on task
    case "$TASK" in
        full)
            log_info "Running full installation..."
            bash "$DOTFILES_DIR/scripts/bootstrap.sh"
            bash "$DOTFILES_DIR/modules/system/packages.sh"
            bash "$DOTFILES_DIR/modules/dev/languages.sh"
            bash "$DOTFILES_DIR/modules/shell/stow.sh"
            # services script coming next
            bash "$DOTFILES_DIR/scripts/post-install.sh"
            ;;
        minimal)
            log_info "Running minimal installation..."
            bash "$DOTFILES_DIR/modules/shell/stow.sh"
            ;;
        dev)
            log_info "Running dev installation..."
            bash "$DOTFILES_DIR/scripts/bootstrap.sh"
            bash "$DOTFILES_DIR/modules/system/packages.sh"
            bash "$DOTFILES_DIR/modules/dev/languages.sh"
            bash "$DOTFILES_DIR/modules/shell/stow.sh"
            bash "$DOTFILES_DIR/scripts/post-install.sh"
            ;;
        *)
            error "Unknown task: $TASK"
            ;;
    esac
    
    echo
    header "Installation Complete!"
    
    log_success "Dotfiles installed successfully"
    log_info "Log file: $LOG_FILE"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo
        log_warning "This was a dry run - no changes were made"
        log_info "Run without --dry-run to apply changes"
    fi
}

# Run main function
main "$@"
