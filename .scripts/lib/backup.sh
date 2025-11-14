#!/usr/bin/env bash


source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

# Create backup
backup_create() {
    local backup_name="${1:-backup-$(date +%Y%m%d-%H%M%S)}"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log_step "Creating backup: $backup_name"
    
    ensure_dir "$backup_path"
    
    # Backup existing dotfiles that will be overwritten
    local files_to_backup=(
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
    
    local backed_up=0
    
    for file in "${files_to_backup[@]}"; do
        if [[ -e "$file" ]] || [[ -L "$file" ]]; then
            local rel_path="${file#$HOME/}"
            local backup_file="$backup_path/$rel_path"
            
            ensure_dir "$(dirname "$backup_file")"
            
            # If it's a symlink, follow it to backup the actual content
            if [[ -L "$file" ]]; then
                local target=$(readlink -f "$file")
                if [[ -e "$target" ]]; then
                    if run cp -rL "$file" "$backup_file"; then
                        log_info "Backed up: $rel_path (symlink -> actual content)"
                        backed_up=$((backed_up + 1))
                    fi
                else
                    log_warning "Skipping broken symlink: $rel_path"
                fi
            else
                # Regular file or directory
                if run cp -r "$file" "$backup_file"; then
                    log_info "Backed up: $rel_path"
                    backed_up=$((backed_up + 1))
                fi
            fi
        fi
    done
    
    # Save package list snapshot
    case "$PLATFORM" in
        linux)
            if [[ "$DISTRO" == "arch" ]]; then
                if command_exists pacman; then
                    pacman -Qqe > "$backup_path/pacman-packages.txt" 2>/dev/null || true
                fi
                if command_exists paru; then
                    paru -Qqm > "$backup_path/aur-packages.txt" 2>/dev/null || true
                fi
            fi
            ;;
        darwin)
            if command_exists brew; then
                brew list --formula > "$backup_path/brew-packages.txt" 2>/dev/null || true
                brew list --cask > "$backup_path/brew-casks.txt" 2>/dev/null || true
            fi
            ;;
    esac
    
    # Create backup metadata
    local hostname_value="unknown"
    if command_exists hostname; then
        hostname_value=$(hostname 2>/dev/null || echo "unknown")
    fi
    
    cat > "$backup_path/metadata.txt" <<EOF
Backup created: $(date)
Platform: $PLATFORM
Distro: $DISTRO
Hostname: $hostname_value
User: $USER
Files backed up: $backed_up
EOF
    
    log_success "Backup created: $backup_path ($backed_up files)"
    echo "$backup_path" > "$BACKUP_DIR/latest"
}

# Restore from backup
backup_restore() {
    local backup_name="$1"
    
    if [[ -z "$backup_name" ]]; then
        if [[ -f "$BACKUP_DIR/latest" ]]; then
            backup_name=$(cat "$BACKUP_DIR/latest")
        else
            error "No backup specified and no latest backup found"
        fi
    fi
    
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [[ ! -d "$backup_path" ]]; then
        backup_path="$backup_name"  # as full path
    fi
    
    if [[ ! -d "$backup_path" ]]; then
        error "Backup not found: $backup_name"
    fi
    
    log_step "Restoring from backup: $backup_path"
    
    if ! confirm "This will overwrite current dotfiles. Continue?"; then
        log_info "Restore cancelled"
        return 1
    fi
    
    # Restore files
    if [[ -d "$backup_path" ]]; then
        find "$backup_path" -type f ! -name "*.txt" -print0 | while IFS= read -r -d '' file; do
            local rel_path="${file#$backup_path/}"
            local target="$HOME/$rel_path"
            
            ensure_dir "$(dirname "$target")"
            
            if run cp -r "$file" "$target"; then
                log_info "Restored: $rel_path"
            fi
        done
    fi
    
    log_success "Restore complete"
}

# List available backups
backup_list() {
    log_info "Available backups:"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_info "No backups found"
        return
    fi
    
    local latest=""
    if [[ -f "$BACKUP_DIR/latest" ]]; then
        latest=$(cat "$BACKUP_DIR/latest")
    fi
    
    for backup in "$BACKUP_DIR"/*; do
        if [[ -d "$backup" ]]; then
            local name=$(basename "$backup")
            local marker=""
            
            if [[ "$backup" == "$latest" ]]; then
                marker=" (latest)"
            fi
            
            if [[ -f "$backup/metadata.txt" ]]; then
                local created=$(grep "Backup created:" "$backup/metadata.txt" | cut -d: -f2-)
                local files=$(grep "Files backed up:" "$backup/metadata.txt" | cut -d: -f2-)
                echo "  $name$marker - $files files -$created"
            else
                echo "  $name$marker"
            fi
        fi
    done
}

# Clean old backups (keep last N)
backup_clean() {
    local keep="${1:-5}"
    
    log_step "Cleaning old backups (keeping last $keep)..."
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_info "No backups to clean"
        return
    fi
    
    local backups=($(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" -printf '%T@ %p\n' | sort -rn | cut -d' ' -f2-))
    local total=${#backups[@]}
    
    if [[ $total -le $keep ]]; then
        log_info "Only $total backups exist, nothing to clean"
        return
    fi
    
    local to_remove=$((total - keep))
    log_info "Removing $to_remove old backup(s)..."
    
    for ((i=keep; i<total; i++)); do
        local backup="${backups[$i]}"
        log_info "Removing: $(basename "$backup")"
        run rm -rf "$backup"
    done
    
    log_success "Cleanup complete"
}
