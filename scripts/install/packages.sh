#!/bin/sh

source $(dirname "$0")/cli/pwd.sh
source $DOTFILES/scripts/cli/colorizer.sh

function install_packages() {
  info "Installing packages"

  find -H "$DOTFILES" -maxdepth 2 -name 'packages' | while read packages
  do
    cat "$packages" | while read package
    do
      info "Installing package: $package"
      $INSTALL_CMD $package
      success "Installed package: $package"
    done
  done
     
  success "Installed packages"
}
