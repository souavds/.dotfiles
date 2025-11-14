#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"
source "$(dirname "${BASH_SOURCE[0]}")/yaml.sh"

# Get list of files to backup from config
get_backup_files() {
  local files=()
  
  # Get individual files
  if command_exists yq; then
    while IFS= read -r file; do
      [[ -n "$file" ]] && files+=("$HOME/$file")
    done < <(yq eval '.files[]' "$CONFIG_DIR/dotfiles.yml" 2>/dev/null)
    
    # Get directories
    while IFS= read -r dir; do
      [[ -n "$dir" ]] && files+=("$HOME/$dir")
    done < <(yq eval '.directories[]' "$CONFIG_DIR/dotfiles.yml" 2>/dev/null)
  else
    # Fallback to hardcoded list if yq not available
    files=(
      "$HOME/.zshrc"
      "$HOME/.gitconfig"
      "$HOME/.ripgreprc"
      "$HOME/.config/nvim"
      "$HOME/.config/tmux"
      "$HOME/.config/kitty"
      "$HOME/.config/ghostty"
      "$HOME/.config/lazygit"
      "$HOME/.config/niri"
      "$HOME/.config/fastfetch"
      "$HOME/.config/ohmyposh"
    )
  fi
  
  printf '%s\n' "${files[@]}"
}

backup_create() {
  local backup_name="${1:-backup-$(date +%Y%m%d-%H%M%S)}"
  local backup_path="$BACKUP_DIR/$backup_name"

  # Check if rsync is available
  if ! command_exists rsync; then
    log_error "rsync is required for backups but not installed"
    log_info "Install with: sudo pacman -S rsync (Arch) or brew install rsync (macOS)"
    return 1
  fi

  log_step "Creating backup: $backup_name"
  ensure_dir "$backup_path"

  local files_to_backup=()
  mapfile -t files_to_backup < <(get_backup_files)

  local backed_up=0

  for file in "${files_to_backup[@]}"; do
    if [[ -e "$file" ]] || [[ -L "$file" ]]; then
      local rel_path="${file#"$HOME"/}"
      local backup_dest="$backup_path/$rel_path"

      ensure_dir "$(dirname "$backup_dest")"

      if [[ -L "$file" ]]; then
        if rsync -aL "$file" "$backup_dest" 2>&1; then
          log_info "Backed up: $rel_path (followed symlink)"
          backed_up=$((backed_up + 1))
        else
          log_warning "Failed to backup: $rel_path"
        fi
      else
        if rsync -a "$file" "$backup_dest" 2>&1; then
          log_info "Backed up: $rel_path"
          backed_up=$((backed_up + 1))
        else
          log_warning "Failed to backup: $rel_path"
        fi
      fi
    fi
  done

  case "$PLATFORM" in
    linux)
      if [[ "$DISTRO" == "arch" ]]; then
        if command_exists pacman; then
          pacman -Qqe >"$backup_path/pacman-packages.txt" 2>/dev/null || true
        fi
        if command_exists paru; then
          paru -Qqm >"$backup_path/aur-packages.txt" 2>/dev/null || true
        fi
      fi
      ;;
    darwin)
      if command_exists brew; then
        brew list --formula >"$backup_path/brew-packages.txt" 2>/dev/null || true
        brew list --cask >"$backup_path/brew-casks.txt" 2>/dev/null || true
      fi
      ;;
  esac

  local hostname_value="${HOSTNAME:-unknown}"
  if command_exists hostname; then
    hostname_value
    hostname_value=$(hostname 2>/dev/null || echo "unknown")
  fi

  cat >"$backup_path/metadata.txt" <<EOF
Backup created: $(date)
Platform: $PLATFORM
Distro: $DISTRO
Hostname: $hostname_value
User: $USER
Files backed up: $backed_up
EOF

  log_success "Backup created: $backup_path ($backed_up files)"
  echo "$backup_path" >"$BACKUP_DIR/latest"
}

backup_restore() {
  local backup_name="$1"
  local preview="${2:-false}"

  if [[ -z "$backup_name" ]]; then
    if [[ -f "$BACKUP_DIR/latest" ]]; then
      backup_name
      backup_name=$(cat "$BACKUP_DIR/latest")
    else
      error "No backup specified and no latest backup found"
    fi
  fi

  local backup_path="$BACKUP_DIR/$backup_name"

  if [[ ! -d "$backup_path" ]]; then
    backup_path="$backup_name"
  fi

  if [[ ! -d "$backup_path" ]]; then
    error "Backup not found: $backup_name"
  fi

  log_step "Restoring from backup: $backup_path"

  if [[ -f "$backup_path/metadata.txt" ]]; then
    log_info "Backup info:"
    grep -E "^(Backup created|Platform|Files backed up):" "$backup_path/metadata.txt" | while read -r line; do
      log_info "  $line"
    done
    echo
  fi

  # Preview mode: show what would be restored
  if [[ "$preview" == "true" ]]; then
    log_info "Files that would be restored:"
    while IFS= read -r -d '' file; do
      if [[ -f "$file" ]] && [[ ! "$file" =~ \.txt$ ]]; then
        local rel_path="${file#"$backup_path"/}"
        local target="$HOME/$rel_path"
        
        if [[ -e "$target" ]]; then
          echo "  $rel_path (exists, would be overwritten)"
        else
          echo "  $rel_path (new)"
        fi
      fi
    done < <(find "$backup_path" -type f -print0)
    return 0
  fi

  if ! confirm "This will overwrite current dotfiles. Continue?"; then
    log_info "Restore cancelled"
    return 1
  fi

  local restored=0
  while IFS= read -r -d '' file; do
    local rel_path="${file#"$backup_path"/}"
    local target="$HOME/$rel_path"

    if [[ -f "$file" ]] && [[ ! "$file" =~ \.txt$ ]]; then
      ensure_dir "$(dirname "$target")"
      if run rsync -a "$file" "$target"; then
        log_info "Restored: $rel_path"
        restored=$((restored + 1))
      fi
    fi
  done < <(find "$backup_path" -type f -print0)

  log_success "Restore complete ($restored files)"
}

backup_list() {
  log_info "Available backups:"

  if [[ ! -d "$BACKUP_DIR" ]]; then
    log_info "No backups found"
    return
  fi

  local latest=""
  if [[ -f "$BACKUP_DIR/latest" ]]; then
    latest
    latest=$(cat "$BACKUP_DIR/latest")
  fi

  for backup in "$BACKUP_DIR"/*; do
    if [[ -d "$backup" ]]; then
      local name
      name=$(basename "$backup")
      local marker=""

      if [[ "$backup" == "$latest" ]]; then
        marker=" (latest)"
      fi

      if [[ -f "$backup/metadata.txt" ]]; then
        local created
        created=$(grep "Backup created:" "$backup/metadata.txt" | cut -d: -f2-)
        local files
        files=$(grep "Files backed up:" "$backup/metadata.txt" | cut -d: -f2-)
        echo "  $name$marker - $files files -$created"
      else
        echo "  $name$marker"
      fi
    fi
  done
}

backup_clean() {
  local keep="${1:-5}"

  log_step "Cleaning old backups (keeping last $keep)..."

  if [[ ! -d "$BACKUP_DIR" ]]; then
    log_info "No backups to clean"
    return
  fi

  local backups=()
  mapfile -t backups < <(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" -printf '%T@ %p\n' | sort -rn | cut -d' ' -f2-)
  local total=${#backups[@]}

  if [[ $total -le $keep ]]; then
    log_info "Only $total backups exist, nothing to clean"
    return
  fi

  local to_remove=$((total - keep))
  log_info "Removing $to_remove old backup(s)..."

  for ((i = keep; i < total; i++)); do
    local backup="${backups[$i]}"
    log_info "Removing: $(basename "$backup")"
    run rm -rf "$backup"
  done

  log_success "Cleanup complete"
}
