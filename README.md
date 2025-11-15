# Dotfiles

Clean and simple dotfiles for Arch Linux and macOS.

## Quick Start

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sh ./bootstrap.sh arch  # or darwin for macOS
```

## Structure

```
.dotfiles/
├── bootstrap.sh              # Main bootstrap script
├── .config/                  # Application configs
├── .scripts/
│   ├── lib/
│   │   └── tui.sh           # UI helpers (logging, prompts)
│   ├── packages/            # Package lists
│   │   ├── arch/            # Arch Linux packages
│   │   │   ├── essential    # Essential packages (stow, git, etc)
│   │   │   └── packages     # All other packages
│   │   └── darwin/          # macOS packages
│   │       ├── essential    # Essential packages
│   │       └── packages     # All other packages
│   ├── arch/                # Arch Linux setup scripts
│   │   ├── 00-essential.sh  # Essential packages & paru
│   │   ├── 01-packages.sh   # User packages
│   │   ├── 02-laptop.sh     # Laptop tools
│   │   ├── 03-shell.sh      # Shell setup
│   │   ├── 04-dotfiles.sh   # Dotfiles symlinks
│   │   ├── 05-security.sh   # Firewall setup
│   │   └── 06-plugins.sh    # Plugin installation (nvim, tmux)
│   └── darwin/              # macOS setup scripts
│       ├── 00-essential.sh  # Homebrew & essentials
│       ├── 01-packages.sh   # User packages
│       ├── 02-shell.sh      # Shell setup
│       ├── 03-dotfiles.sh   # Dotfiles symlinks
│       └── 04-plugins.sh    # Plugin installation (nvim, tmux)
└── .cp/                    # System config files (PAM, systemd, etc)
```

## How It Works

1. **bootstrap.sh** detects your system (arch/darwin)
2. Runs all `.sh` scripts in `.scripts/<system>/` in alphabetical order
3. Each script is independent and can prompt for user input
4. Scripts read package lists from `.scripts/packages/<system>/`

## Adding New Scripts

Create a new script in `.scripts/arch/` or `.scripts/darwin/`:

```bash
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "My Custom Setup"

# Your setup code here
log_info "Doing something..."

if confirm "Install optional thing?"; then
  # Install optional thing
fi

log_success "Setup complete"
```

Scripts run in alphabetical order, so use prefixes:
- `00-` for essentials
- `01-` for packages
- `02-` and up for everything else

## Package Management

Package lists are stored in `.scripts/packages/<system>/`:

- **essential** - Required packages for bootstrap (stow, git, curl, etc)
- **packages** - All other packages (one per line, comments start with `#`)

Example `.scripts/packages/arch/packages`:

```
# Shell tools
neovim
bat
ripgrep

# Development
lazygit
docker
```

## Included Configurations

- **Shell**: zsh with oh-my-posh
- **Editor**: neovim
- **Terminal**: ghostty, kitty, tmux
- **Dev Tools**: mise, lazygit, lazydocker
- **CLI Tools**: bat, eza, zoxide, fzf, ripgrep, yazi

## Arch Linux Specific

- Installs paru (AUR helper) during bootstrap
- All packages installed via paru (handles both official repos and AUR)
- Batch installation for faster setup
- Laptop tools: thermald, auto-cpufreq, acpi
- Fingerprint reader setup (interactive enrollment at the end)
- Firewall (ufw) configuration
- Automatic plugin installation (nvim, tmux)

## macOS Specific

- Installs Homebrew
- Uses brew for all package management
- Batch installation for faster setup
- Automatic plugin installation (nvim, tmux)

## Post-Installation

1. Restart your shell: `exec zsh`
2. Update firmware (Arch): `fwupdmgr update`

Note: tmux and neovim plugins are installed automatically during bootstrap!

## License

MIT
