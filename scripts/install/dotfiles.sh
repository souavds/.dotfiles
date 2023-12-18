#!/bin/sh

source $(dirname "$0")/cli/pwd.sh
source $DOTFILES/scripts/cli/colorizer.sh
source $DOTFILES/scripts/cli/symlink.sh

function install_dotfiles() {
  info "Installing dotfiles"

  local overwrite_all=false backup_all=false skip_all=false

  find -H "$DOTFILES" -maxdepth 2 -name 'links.prop' | while read linkfile
  do
    cat "$linkfile" | while read line
    do
        local src dst dir
        src=$(eval echo "$line" | cut -d '=' -f 1)
        dst=$(eval echo "$line" | cut -d '=' -f 2)
        dir=$(dirname $dst)

        mkdir -p "$dir"
        symlink "$src" "$dst"
    done
  done

  success "Installed dotfiles"
}
