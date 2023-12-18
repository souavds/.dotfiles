#!/bin/sh

source $(dirname "$0")/cli/pwd.sh
source $DOTFILES/scripts/cli/colorizer.sh

source $DOTFILES/scripts/install/get_install_cmd.sh
source $DOTFILES/scripts/install/shell.sh
source $DOTFILES/scripts/install/packages.sh
source $DOTFILES/scripts/install/dotfiles.sh

info "Initiating setup..."
get_install_cmd
install_shell
install_packages
install_dotfiles
success "Finished setup"


