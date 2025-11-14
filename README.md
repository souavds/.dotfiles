# souavds' dotfiles

Personal dotfiles for Arch Linux and macOS.

## Installation

```bash
git clone git@github.com:souavds/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
just install
```

## Requirements

- `git`
- `stow`
- `just`

## Available Commands

```bash
just install          # Full installation
just minimal          # Dotfiles only
just dev              # Development environment

just packages         # Install packages
just languages        # Setup programming languages
just dotfiles         # Symlink dotfiles
just fonts            # Install fonts

just backup [name]    # Create backup
just restore [name]   # Restore backup
just list-backups     # List available backups

just info             # Show system info
just test             # Test scripts
just format           # Format scripts
just lint             # Lint scripts
just check            # Format and lint
```

## Structure

```
.dotfiles/
├── .config/          # Configuration files (stowed to ~)
├── .scripts/         # Installation scripts
│   ├── lib/          # Core libraries
│   ├── modules/      # Installation modules
│   └── config/       # YAML manifests
└── Justfile          # Task definitions
```

## Configuration

Edit YAML files in `.scripts/config/`:

- `packages.yml` - System packages
- `languages.yml` - Programming languages (mise)
- `services.yml` - System services
- `dotfiles.yml` - Files to backup/manage

## Notes

Backups are automatically created before any destructive operations in `.backups/`.

Machine: ThinkPad T14 Gen 5 - Intel Ultra 5 135U - 64GB DDR5
