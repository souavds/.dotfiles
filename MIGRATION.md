# Migration Guide: Old to New Installation System

## Overview

This guide helps you migrate from the old `.scripts/` based system to the new modular `Shell + YAML + Justfile` system.

## What's Changed?

### Old System
- Monolithic scripts (`.scripts/host/arch.sh`, `.scripts/host/darwin.sh`)
- Package lists in `.txt` files
- No backup mechanism
- Manual error handling
- Not idempotent

### New System
- ✅ Modular architecture (`lib/`, `modules/`, `platforms/`)
- ✅ YAML-based manifests (`config/*.yml`)
- ✅ Automatic backups before changes
- ✅ Comprehensive error handling
- ✅ Idempotent - safe to re-run
- ✅ Dry-run mode
- ✅ Task-based installation (Justfile)

## Migration Steps

### 1. Review Your Current Setup

```bash
cd ~/.dotfiles

# Your dotfiles are safe - nothing changes them
# Old scripts are preserved in .scripts/
```

### 2. Test New System (Dry Run)

```bash
# Preview what would happen without making changes
./install.sh --dry-run
```

### 3. Customize Packages (Optional)

If you had custom packages in old `.txt` files, add them to `config/packages.yml`:

```bash
# Review your old package lists
cat .scripts/packages.txt
cat .scripts/arch-packages.txt

# Edit the new YAML manifest
nvim config/packages.yml
```

### 4. Run New Installer

```bash
# Option A: Full installation
./install.sh

# Option B: Minimal (just dotfiles)
./install.sh --task minimal

# Option C: Using Just
just install
```

### 5. Verify Installation

```bash
# Check logs
tail -f install.log

# Verify symlinks
ls -la ~/.zshrc ~/.gitconfig ~/.config/nvim

# Check backups were created
ls -la .backups/
```

## Package Mapping

### Old `.scripts/packages.txt` → New `config/packages.yml`

**Old:**
```txt
stow
neovim
git
bat
```

**New:**
```yaml
common:
  essential:
    - stow
    - neovim
    - git
    - bat
```

### Old `.scripts/arch-packages.txt` → New `config/packages.yml`

**Old:**
```txt
opencode-bin
spotify
```

**New:**
```yaml
arch:
  aur:
    - opencode-bin
    - spotify
```

## Command Mapping

| Old Command | New Command |
|-------------|-------------|
| `sh .scripts/host/arch.sh` | `./install.sh` or `just install` |
| `sh .scripts/host/darwin.sh` | `./install.sh` or `just install` |
| `stow -D . && stow .` | `just dotfiles` |
| `sh .scripts/lib/mimeapps.sh` | (Still works as-is) |

## Feature Comparison

### Backup & Restore

**Old:** No backups ❌

**New:**
```bash
# Automatic backup before installation
./install.sh  # Creates backup automatically

# Manual backup
just backup my-backup-name

# Restore
just restore my-backup-name

# List backups
just list-backups
```

### Dry Run

**Old:** Not available ❌

**New:**
```bash
./install.sh --dry-run
```

### Modular Installation

**Old:** All-or-nothing ❌

**New:**
```bash
just install         # Full
just install-minimal # Dotfiles only
just install-dev     # Dev environment
just packages        # Just packages
just languages       # Just languages
```

## Troubleshooting

### "My packages aren't in the new YAML"

Add them manually to `config/packages.yml`:

```yaml
common:
  custom:
    - your-package-here
```

### "I want to use the old scripts"

They still work! They're preserved in `.scripts/`:

```bash
sh .scripts/host/arch.sh  # Old way still works
```

But we recommend migrating to the new system for better reliability.

### "Something went wrong"

Restore from backup:

```bash
# List available backups
just list-backups

# Restore
just restore backup-20240315-143022
```

## What to Keep, What to Remove

### Keep
- `.config/` - Your dotfiles (unchanged)
- `.cp/` - System config templates (unchanged)
- `.templates/` - File templates (unchanged)
- `.ssh/` - SSH config (unchanged)
- `.scripts/` - Old scripts (for reference, can be removed after migration)

### New Files
- `lib/` - Core libraries
- `modules/` - Installation modules
- `platforms/` - Platform adapters
- `scripts/` - Helper scripts
- `config/` - YAML manifests
- `Justfile` - Task definitions
- `install.sh` - Main entry point

## FAQ

**Q: Do I need to uninstall the old system first?**
A: No! The new system coexists peacefully. Your dotfiles remain the same.

**Q: Will my existing symlinks break?**
A: No, stow manages the same files. The new system creates identical symlinks.

**Q: Can I still use the old scripts?**
A: Yes, they're preserved in `.scripts/` for backward compatibility.

**Q: What if I don't want to install all packages?**
A: Use interactive mode - the installer asks before each category.

**Q: How do I roll back?**
A: Backups are automatic. Use `just restore` to roll back.

**Q: Do I need to learn Just?**
A: No! You can use `./install.sh` directly. Just is optional but convenient.

## Post-Migration Cleanup (Optional)

After successfully migrating and testing, you can optionally remove old files:

```bash
# DO NOT do this until you've tested the new system!

# Remove old scripts (optional, keep for reference)
# rm -rf .scripts/

# Old package lists (data is now in config/packages.yml)
# The old .txt files can be kept for reference
```

## Getting Help

If something goes wrong:

1. Check the logs: `tail -f install.log`
2. Restore from backup: `just restore`
3. Run validation: `bash -c "source lib/validation.sh && validate_all"`
4. Use dry-run to debug: `./install.sh --dry-run`

## Migration Checklist

- [ ] Backed up current dotfiles
- [ ] Reviewed `config/packages.yml`
- [ ] Added custom packages to YAML if needed
- [ ] Tested with `--dry-run`
- [ ] Ran new installer
- [ ] Verified symlinks
- [ ] Tested shell, nvim, tmux
- [ ] Checked backups were created
- [ ] Old scripts still available in `.scripts/` (optional backup)

---

Welcome to the new dotfiles automation system! 🎉
