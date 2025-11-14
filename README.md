# souavds' dotfiles

Modern dotfiles automation using **Shell + YAML + Justfile**

```
machine:
thinkpad t14 gen 5 - intel ultra 5 135u - 64gb ram ddr5
```

## Features

- Modular architecture with separation of concerns
- YAML-based package manifests (easy to read and modify)
- Task-based installation (full, minimal, dev profiles)
- Automatic backups before destructive operations
- Idempotent - safe to re-run
- Dry-run mode to preview changes
- Cross-platform (Arch Linux + macOS)
- Interactive prompts with `gum` (with fallbacks)
- Comprehensive error handling and logging

## Quick Start

### Fresh Install

```bash
git clone git@github.com:souavds/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Option 1: Full installation (recommended)
./install.sh

# Option 2: Using Just
just install

# Option 3: Minimal (dotfiles only, no packages)
./install.sh --task minimal
# or
just install-minimal

# Option 4: Dev environment
just install-dev
```

### Dry Run (Preview Changes)

```bash
./install.sh --dry-run
```

### Update Existing Installation

```bash
cd ~/.dotfiles
git pull

# Update packages
just update

# Re-apply dotfiles
just dotfiles

# Update mise tools
just mise-update
```

## Project Structure

```
.dotfiles/
├── install.sh              # Main entry point
├── Justfile                # Task orchestration
│
├── lib/                    # Core libraries
│   ├── core.sh             # Logging, platform detection, utilities
│   ├── ui.sh               # Interactive prompts (gum wrapper)
│   ├── validation.sh       # Pre-flight checks
│   ├── backup.sh           # Backup/restore functionality
│   └── yaml.sh             # YAML parsing
│
├── modules/                # Installation modules
│   ├── system/
│   │   └── packages.sh     # Package installation
│   ├── dev/
│   │   └── languages.sh    # Language runtimes (mise)
│   └── shell/
│       └── stow.sh         # Dotfile symlinking
│
├── platforms/              # Platform-specific code
│   ├── arch/
│   │   └── package-manager.sh
│   └── darwin/
│       └── package-manager.sh
│
├── scripts/                # Helper scripts
│   ├── bootstrap.sh        # Initial setup
│   └── post-install.sh     # Post-installation tasks
│
├── config/                 # YAML manifests
│   ├── packages.yml        # Package definitions
│   ├── languages.yml       # Language runtimes
│   └── services.yml        # System services
│
└── .config/                # Actual dotfiles (stowed)
    ├── nvim/
    ├── tmux/
    ├── kitty/
    └── ...
```

## Available Commands

### Installation Tasks

```bash
# Full installation
just install

# Minimal (dotfiles only)
just install-minimal

# Development environment
just install-dev

# Individual components
just packages      # Install packages
just languages     # Install language runtimes
just dotfiles      # Symlink dotfiles
just fonts         # Install fonts
```

### Maintenance

```bash
# Update packages
just update

# Create backup
just backup [name]

# List backups
just list-backups

# Restore from backup
just restore [name]

# Clean old backups (keep last 5)
just clean-backups
```

### Utilities

```bash
# Show system info
just info

# Dry run (preview changes)
./install.sh --dry-run

# Test scripts (syntax check)
just test

# View all available commands
just --list
```

## Configuration

### Package Management

Edit `config/packages.yml` to add/remove packages:

```yaml
common:
  essential:
    - git
    - stow
    - neovim
  
  shell:
    - bat
    - eza
    - fzf

arch:
  aur:
    - opencode-bin
    - spotify
```

### Language Runtimes

Edit `config/languages.yml`:

```yaml
tools:
  node:
    version: latest
  erlang:
    version: latest
    env:
      KERL_CONFIGURE_OPTIONS: "--enable-wx"
```

## Platform Support

### Arch Linux

- Package manager: `pacman` + `paru` (AUR helper)
- Automatic installation of AUR helper
- Laptop-specific optimizations (auto-cpufreq, thermald, etc.)
- System service configuration

### macOS

- Package manager: Homebrew
- Automatic Homebrew installation if missing
- Native macOS app support via casks

## Backup & Restore

Automatic backups are created before any destructive operations:

```bash
# Backups are stored in .backups/
ls .backups/

# Restore from backup
just restore backup-20240315-143022

# List all backups
just list-backups
```

## Dotfile Highlights

- **ZSH**: zinit plugin manager, oh-my-posh theme, modern CLI tools
- **Neovim**: mini.nvim based config, LSP, tree-sitter
- **Tmux**: catppuccin theme, popup lazygit, nvim integration
- **Kitty/Ghostty**: CommitMono Nerd Font, consistent config
- **Git**: 1Password SSH signing, sensible defaults

## Migration from Old System

The old installation scripts (`.scripts/`) are preserved but deprecated. To migrate:

```bash
# The new system coexists with the old one
# Your dotfiles remain unchanged

# Test the new system with dry-run
./install.sh --dry-run

# When ready, run the new installer
./install.sh

# Old scripts remain in .scripts/ for reference
```

## Troubleshooting

### Check logs

```bash
tail -f install.log
```

### Validation failures

```bash
# Run validation separately
bash -c "source lib/validation.sh && validate_all"
```

### Restore dotfiles

```bash
# If something goes wrong
just restore
# or
just uninstall  # Remove symlinks
```

### Missing dependencies

The bootstrap script should install `gum`, but if it fails:

```bash
# Arch
sudo pacman -S gum

# macOS
brew install gum
```

## Advanced Usage

### Custom Installation

```bash
# Skip validation (not recommended)
./install.sh --skip-validation

# Verbose output
./install.sh --verbose

# Create backup with custom name
./install.sh --backup my-backup-name
```

### Environment Variables

```bash
# Dry run mode
DRY_RUN=true ./install.sh

# Custom dotfiles directory
DOTFILES_DIR=/path/to/dotfiles ./install.sh
```

## Development

### Testing Scripts

```bash
# Syntax check all scripts
just test

# Lint with shellcheck (if installed)
just lint

# Format with shfmt (if installed)
just format
```

### Adding New Packages

1. Edit `config/packages.yml`
2. Add package to appropriate category
3. Run `just packages` to install

### Adding New Modules

1. Create script in `modules/[category]/`
2. Source core libraries
3. Add to Justfile
4. Add to install.sh if needed

## Credits

- Inspired by modern dotfile managers
- Built with bash, YAML, and Just
- Uses GNU Stow for symlink management
- UI powered by gum (charmbracelet)

## License

MIT - Feel free to use and modify

---

## Old Installation Method (Deprecated)

The old scripts are still available in `.scripts/` but are no longer maintained:

```bash
# Old method (still works, but not recommended)
sh ./.scripts/host/arch.sh
sh ./.scripts/host/darwin.sh
```

Please use the new installation system documented above.
