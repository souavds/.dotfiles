#!/bin/sh

cd "$(dirname "$0")"
export DOTFILES=$(pwd -P)

SYMBOL="\uf444"
USER_INPUT_MARGIN="   "

info () {
  printf "\033[00;34m $SYMBOL $1 \033[0m\n"
}

user () {
  printf "\033[0;33m $SYMBOL $1 \033[0m\n"
}

success () {
  printf "\033[00;32m $SYMBOL $1 \033[0m\n"
}

fail () {
  printf "\033[0;31m $SYMBOL $1 \033[0m\n"
  echo ''
  exit
}

command=

function get_install_command() {
  user "What is the install command in your system? (i.e. brew install)"
  read -p "$USER_INPUT_MARGIN" command < /dev/tty
}

function install_shell() {
  info "Installing fish shell"
  
  $command fish

  user "Do you want to make fish the default shell? (y/n)"
  read -p "$USER_INPUT_MARGIN" yn < /dev/tty

  case $yn in
    [Yy]* ) chsh -s $(which fish) ;;
    [Nn]* ) info "> Skipped" ;;
    * ) info "> Incorrect option, skipping";;
  esac

  success "Installed fish shell"
}

function install_packages() {
  info "Installing packages"

  find -H "$DOTFILES" -maxdepth 2 -name 'packages' | while read packagesfile
  do
    cat "$packagesfile" | while read line
    do
      info "Installing package: $line"
      $command $line
      success "Installed package: $line"
    done
  done
     
  success "Installed packages"
}

function link_file() {
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

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action  < /dev/tty

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
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

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "Successfully symlinked files $1 -> $2"
  fi 
}

function install_dotfiles() {
  info "Installing dotfiles"

  local overwrite_all=false backup_all=false skip_all=false

  find -H "$DOTFILES" -maxdepth 2 -name 'linking' | while read linkfile
  do
    cat "$linkfile" | while read line
    do
        local src dst dir
        src=$(eval echo "$line" | cut -d '=' -f 1)
        dst=$(eval echo "$line" | cut -d '=' -f 2)
        dir=$(dirname $dst)

        mkdir -p "$dir"
        link_file "$src" "$dst"
    done
  done

  success "Installed dotfiles"
}

function install_asdf() {
  info "Installing asdf"

  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
  mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions;
}


info "Initiating setup..."
get_install_command
install_shell
install_packages
install_dotfiles
success "Finished setup"


