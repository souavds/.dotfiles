#!/bin/sh

source $(dirname "$0")/cli/pwd.sh
source $DOTFILES/scripts/cli/colorizer.sh

function symlink() {
  local src=$1 dst=$2

  local overwrite=
  local backup=
  local skip=
  local action=

  if [ -f "$dst" ] || [ -d "$dst" ] || [ -L "$dst" ]
  then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then
      # ignoring exit 1 from readlink in case where file already exists
      # shellcheck disable=SC2155
      local currentSrc="$(readlink $dst)"
      
      if [ "$currentSrc" == "$src" ]
      then
        skip=true;
      else
        user action -n "File already exists: $dst ($(basename "$src")), what do you want to do?\n
        $USER_INPUT_MARGIN[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"

        case "$action" in
          o ) overwrite=true;;
          O ) overwrite_all=true;;
          b ) backup=true;;
          B ) backup_all=true;;
          s ) skip=true;;
          S ) skip_all=true;;
          * ) ;;
        esac
      fi
    fi
    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      local time="$(date + "%s")"
      local bkp_file="$dst.backup($time)"
      mv "$dst" "$bkp_file"
      success "moved $dst to $bkp_file"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]
  then
    ln -s "$1" "$2"
    success "symlinked files $1 -> $2"
  fi 
}
