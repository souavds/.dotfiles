#!/bin/sh

source ./scripts/cli/colorizer.sh

function perform_system_update() {
  info "Updating system"

  yes y | sudo pacman -Syu --noconfirm

  success "System updated"
}

function install_git() {
  info "Installing git"

  yes y | sudo pacman -S git

  success "Installed git"
}

function install_aur_helper() {
  info "Installing paru as aur helper"

  yes y | sudo pacman -S --needed base-devel
  git clone https://aur.archlinux.org/paru-git.git paru
  (cd paru && yes y | makepkg -si)
  rm -rf paru

  success "Installed paru"
} 

function install_shell() {
  info "Installing zsh shell"
  
  yes y | paru -S zsh

  chsh -s $(which zsh) && zsh

  success "Installed zsh shell"
}

function install_packages() {
  info "Installing packages"

  yes y | paru -S - < ./scripts/packages 

  success "Installed all packages"
}

function install_languages() {
  info "Installing languages"

  yes y | paru -S jdk-openjdk unixodbc ncurses libssh wxwidgets-gtk3 wxwidgets-common unzip

  mise use -g node go
  KERL_CONFIGURE_OPTIONS="--enable-wx" mise use -g erlang
  mise use -g elixir
  mise reshim

  success "Installed languages"
}

function setup_shell() {
  info "Setting up shell"

  mise use -g usage

  success "Finished setting up shell"
}

info "Initiating arch linux setup"
perform_system_update
install_git
install_aur_helper
install_shell
install_languages
setup_shell
success "Finished arch linux setup"
