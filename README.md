# Dotfiles

Clean dotfiles for Arch Linux and macOS.

## Quick Start

```bash
git clone https://github.com/souavds/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sh ./bootstrap.sh arch  # or darwin for macOS
```

## Structure

```
.dotfiles/
├── bootstrap.sh
├── .config/              # App configurations
├── .scripts/
│   ├── lib/
│   │   └── tui.sh       # UI helpers (gum)
│   ├── packages/
│   │   ├── arch/
│   │   │   ├── essential
│   │   │   └── packages
│   │   └── darwin/
│   │       ├── essential
│   │       └── packages
│   ├── arch/
│   │   ├── 00-essential.sh
│   │   ├── 01-packages.sh
│   │   ├── 02-laptop.sh
│   │   ├── 03-shell.sh
│   │   ├── 04-dotfiles.sh
│   │   ├── 05-security.sh
│   │   └── 06-plugins.sh
│   └── darwin/
│       ├── 00-essential.sh
│       ├── 01-packages.sh
│       ├── 02-shell.sh
│       ├── 03-dotfiles.sh
│       └── 04-plugins.sh
└── .cp/                  # System configs (PAM, systemd, etc)
```

## How It Works

1. Run `bootstrap.sh` with `arch` or `darwin`
2. Scripts run in alphabetical order
3. Packages install in batch (fast)
4. Plugins install automatically (nvim, tmux)

## Package Management

Two files per system:
- `essential` - Bootstrap requirements
- `packages` - Everything else

Add packages (one per line):
```
neovim
bat
ripgrep
```

## Included

- **Shell**: zsh + oh-my-posh
- **Editor**: neovim + mini.deps
- **Terminal**: ghostty, kitty, tmux
- **Dev**: mise, lazygit, lazydocker, docker
- **CLI**: bat, eza, zoxide, fzf, ripgrep, yazi

## Arch Linux

- Batch installation via paru
- Laptop tools: thermald, auto-cpufreq, acpi
- Fingerprint reader setup
- Firewall (ufw)
- Auto plugin install

## macOS

- Homebrew
- Batch installation
- Auto plugin install

## Post-Install

1. Restart shell: `exec zsh`
2. Update firmware (Arch): `fwupdmgr update`

Plugins install automatically!

## License

MIT
