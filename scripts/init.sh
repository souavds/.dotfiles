#!/bin/sh

cd "$(dirname "$0")"
export DOTFILES=$(pwd -P)

SYMBOL="\uf444"

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
  read -p "   " command < /dev/tty
}

function install_shell() {
  info "Installing fish shell"
  
  $command fish

  read -p "Do you want to make fish the default shell? (y/n) " yn < /dev/tty

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

  local skip=
  local overwrite=
  local backup=
  local action=

  if [ -f "$dst" ] || [ -d "$dst" ] || [ -L "$dst" ]
  then

    local first_line="Path to $dst already exists, what do you want to do?"
    local second_line="[o]verwrite, [s]kip, [S]kip all, [b]ackup?"
    read -p "$first_line $second_line " yn < /dev/tty

    case $yn in
      [S]* ) echo "> Skipped symlinking all duplicated files"; break ;;
      [s]* ) echo "> Skipped symlinking $(basename "$src")"; skip=true ;;
      [o]* ) overwrite=true ;;
      [b]* ) backup=true ;;
      * ) echo "> Incorrect option, skipping"; skip=true ;;
    esac


    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      echo "> Removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      local timestamp = $(date +%s)
      local backup = "${dst}.backup($timestamp)"
      mv "$dst" "$backup"
      echo "> Moved $dst to $backup"
    fi

  fi

  if [ "$skip" != "true" ]
  then
    ln -s "$src" "$dst"
    echo "> Linked $1 to $2"
  fi

  echo ""
}

function install_dotfiles() {
  info "Installing dotfiles"

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


