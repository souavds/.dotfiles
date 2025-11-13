# Justfile for dotfiles installation and management
# Run `just --list` to see all available commands

# Default recipe (shows help)
default:
    @just --list

# Install everything (full setup)
install: validate bootstrap packages languages services dotfiles post-install
    @echo "✓ Full installation complete!"

# Minimal install (just dotfiles)
install-minimal: validate dotfiles
    @echo "✓ Minimal installation complete!"

# Development environment only
install-dev: validate bootstrap packages languages dotfiles
    @echo "✓ Development environment ready!"

# Validate system requirements
validate:
    @echo "→ Running pre-flight checks..."
    @bash -c "source lib/validation.sh && validate_all"

# Bootstrap (install essential tools)
bootstrap:
    @echo "→ Bootstrapping system..."
    @bash scripts/bootstrap.sh

# Install packages
packages:
    @echo "→ Installing packages..."
    @bash modules/system/packages.sh

# Install programming languages
languages:
    @echo "→ Setting up programming languages..."
    @bash modules/dev/languages.sh

# Configure system services
services:
    @echo "→ Configuring system services..."
    @bash modules/system/services.sh

# Symlink dotfiles with stow
dotfiles:
    @echo "→ Symlinking dotfiles..."
    @bash modules/shell/stow.sh

# Post-installation tasks
post-install:
    @echo "→ Running post-install tasks..."
    @bash scripts/post-install.sh

# Update packages
update:
    @echo "→ Updating packages..."
    @bash scripts/update.sh

# Create backup
backup name="":
    @echo "→ Creating backup..."
    @bash -c "source lib/backup.sh && backup_create '{{name}}'"

# Restore from backup
restore name="":
    @echo "→ Restoring from backup..."
    @bash -c "source lib/backup.sh && backup_restore '{{name}}'"

# List backups
list-backups:
    @bash -c "source lib/backup.sh && backup_list"

# Clean old backups (keep last 5)
clean-backups:
    @bash -c "source lib/backup.sh && backup_clean"

# Dry run (preview changes without applying)
dry-run:
    @echo "→ Dry run mode..."
    @DRY_RUN=true bash scripts/install.sh

# Uninstall dotfiles (remove symlinks)
uninstall:
    @echo "→ Removing dotfiles symlinks..."
    @cd "{{justfile_directory()}}" && stow -D .

# Install fonts
fonts:
    @echo "→ Installing fonts..."
    @bash modules/desktop/fonts.sh

# Setup ZSH
zsh:
    @echo "→ Setting up ZSH..."
    @bash modules/shell/zsh.sh

# Setup Tmux
tmux:
    @echo "→ Setting up Tmux..."
    @bash modules/shell/tmux.sh

# Update mise tools
mise-update:
    @echo "→ Updating mise tools..."
    @mise upgrade
    @mise prune

# Clean temporary files
clean:
    @echo "→ Cleaning temporary files..."
    @rm -rf tmp/
    @echo "✓ Cleaned"

# Show system information
info:
    @echo "Platform: $(uname -s)"
    @echo "Distro: $(cat /etc/os-release 2>/dev/null | grep ^ID= | cut -d= -f2)"
    @echo "Dotfiles: {{justfile_directory()}}"
    @echo "User: $USER"
    @echo "Home: $HOME"

# Test installation scripts (syntax check)
test:
    @echo "→ Testing scripts..."
    @find lib modules platforms scripts -name "*.sh" -type f -exec bash -n {} \;
    @echo "✓ All scripts passed syntax check"

# Format shell scripts (requires shfmt)
format:
    @if command -v shfmt >/dev/null 2>&1; then \
        echo "→ Formatting shell scripts..."; \
        find lib modules platforms scripts -name "*.sh" -type f -exec shfmt -w -i 4 {} \;; \
        echo "✓ Formatted"; \
    else \
        echo "shfmt not installed, skipping format"; \
    fi

# Lint shell scripts (requires shellcheck)
lint:
    @if command -v shellcheck >/dev/null 2>&1; then \
        echo "→ Linting shell scripts..."; \
        find lib modules platforms scripts -name "*.sh" -type f -exec shellcheck {} \;; \
    else \
        echo "shellcheck not installed, skipping lint"; \
    fi
