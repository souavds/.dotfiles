#!/bin/sh

source $(dirname "$0")/cli/pwd.sh
source $DOTFILES/scripts/cli/colorizer.sh

function perform_system_update() {
  info "Updating system"

  yes y | pacman -Syu

  success "System updated"
}

function install_git() {
  info "Installing git"

  yes y | pacman -S git

  success "Installed git"
}

function install_aur_helper() {
  info "Installing paru as aur helper"

  yes y | pacman -S --needed base-devel
  git clone https://aur.archlinux.org/paru.git
  (cd paru && yes y | makepkg -si)

  success "Installed paru"
} 

function install_shell() {
  info "Installing fish shell"
  
  yes y | paru -S fish

  chsh -s $(which fish) && fish

  success "Installed fish shell"
}

function install_packages() {
  info "Installing packages"

  yes y | paru -S - < $DOTFILES/scripts/packages 

  success "Installed all packages"
}

info "Initiating arch linux setup"
perform_system_update
install_git
install_aur_helper
install_shell
