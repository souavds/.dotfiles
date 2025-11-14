# Dotfiles Management
# Run `just --list` to see all available commands

default:
    @just --list

# Full installation (everything)
install: bootstrap packages languages services dotfiles
    @echo "✓ Full installation complete!"

# Minimal install (just dotfiles)
minimal: dotfiles
    @echo "✓ Minimal installation complete!"

# Development environment
dev: bootstrap packages languages dotfiles
    @echo "✓ Development environment ready!"

# Bootstrap system (install essential tools like yq, paru)
bootstrap:
    @echo "→ Bootstrapping system..."
    @bash .scripts/bootstrap.sh

# Install packages from YAML
packages:
    @echo "→ Installing packages..."
    @bash .scripts/modules/system/packages.sh

# Install programming languages via mise
languages:
    @echo "→ Setting up programming languages..."
    @bash .scripts/modules/dev/languages.sh

# Configure system services (Arch Linux laptop tools)
services:
    @echo "→ Configuring system services..."
    @bash .scripts/modules/system/services.sh

# Symlink dotfiles with stow
dotfiles:
    @echo "→ Symlinking dotfiles..."
    @bash .scripts/modules/shell/stow.sh

# Post-installation tasks
post-install:
    @echo "→ Running post-install tasks..."
    @bash .scripts/post-install.sh

# Create backup
backup name="":
    @echo "→ Creating backup..."
    @bash -c "export DOTFILES_DIR={{justfile_directory()}} && source .scripts/lib/core.sh && source .scripts/lib/ui.sh && source .scripts/lib/backup.sh && backup_create '{{name}}'"

# Restore from backup
restore name="":
    @echo "→ Restoring from backup..."
    @bash -c "export DOTFILES_DIR={{justfile_directory()}} && source .scripts/lib/core.sh && source .scripts/lib/ui.sh && source .scripts/lib/backup.sh && backup_restore '{{name}}'"

# Preview backup restore (dry-run)
restore-preview name="":
    @echo "→ Previewing backup restore..."
    @bash -c "export DOTFILES_DIR={{justfile_directory()}} && source .scripts/lib/core.sh && source .scripts/lib/ui.sh && source .scripts/lib/backup.sh && backup_restore '{{name}}' true"

# List backups
list-backups:
    @bash -c "export DOTFILES_DIR={{justfile_directory()}} && source .scripts/lib/core.sh && source .scripts/lib/backup.sh && backup_list"

# Clean old backups (keep last 5)
clean-backups:
    @bash -c "export DOTFILES_DIR={{justfile_directory()}} && source .scripts/lib/core.sh && source .scripts/lib/backup.sh && backup_clean"

# Uninstall dotfiles (remove symlinks)
uninstall:
    @echo "→ Removing dotfiles symlinks..."
    @cd "{{justfile_directory()}}" && stow -D .

# Install Nerd Fonts
fonts:
    @echo "→ Installing fonts..."
    @bash .scripts/modules/desktop/fonts.sh

# Setup ZSH
zsh:
    @echo "→ Setting up ZSH..."
    @bash .scripts/modules/shell/zsh.sh

# Setup Tmux
tmux:
    @echo "→ Setting up Tmux..."
    @bash .scripts/modules/shell/tmux.sh

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
    @bash -c "export DOTFILES_DIR={{justfile_directory()}} && source .scripts/lib/core.sh && echo \"Platform: \$PLATFORM\" && echo \"Distro: \$DISTRO\" && echo \"Dotfiles: {{justfile_directory()}}\" && echo \"User: \$USER\" && echo \"Home: \$HOME\""

# Test all scripts (syntax check)
test:
    @echo "→ Testing scripts..."
    @find .scripts -name "*.sh" -type f -exec bash -n {} \;
    @echo "✓ All scripts passed syntax check"

# Format all shell scripts
format:
    @echo "→ Formatting shell scripts..."
    @shfmt -w -i 2 -ci -bn .scripts/**/*.sh .scripts/*.sh
    @echo "✓ Scripts formatted"

# Lint all shell scripts with shellcheck
lint:
    @echo "→ Linting shell scripts..."
    @shellcheck .scripts/**/*.sh .scripts/*.sh
    @echo "✓ All scripts passed linting"

# Format and lint all scripts
check: format lint
    @echo "✓ All checks passed"
