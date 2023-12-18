#!/bin/sh

source $(dirname "$0")/cli/pwd.sh
source $DOTFILES/scripts/cli/colorizer.sh

function install_shell() {
  info "Installing fish shell"
  
  $INSTALL_CMD fish

  user yn -p "Do you want to make fish the default shell? (y/n)"

  case $yn in
    [Yy]* ) chsh -s $(which fish) ;;
    [Nn]* ) info "> Skipped" ;;
    * ) info "> Incorrect option, skipping";;
  esac

  success "Installed fish shell"
}
