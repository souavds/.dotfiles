#!/usr/bin/env sh

source ./.scripts/lib/preinstall.sh
source ./.scripts/lib/terminal/tui.sh
source ./.scripts/lib/common.sh
source ./.scripts/lib/cleanup.sh

function check_and_install() {
  if ! command -v $1 &> /dev/null
  then
    brew install $1
  fi
}

function install_brew() {
  echo ">>> Brew"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo "<<< Brew"
}

function system_update() {
  log ">>> Update system"

  brew update && brew upgrade

  log "<<< Update system"
}

function install_git() {
  log ">>> Git"

  brew install git

  log "<<< Git"
}

function install_zsh() {
  log ">>> ZSH"
  
  brew install zsh

  gum confirm "Do you want to make zsh the default shell?" && (chsh -s $(which zsh) && zsh)

  log "<<< ZSH"
}

function packages() {
  log ">>> Packages"

  PACKAGES=$(cat ./.scripts/packages.txt | gum choose --no-limit --header "Which packages would you like to install?")
  brew install $PACKAGES

  log "<<< Packages"
}

echo ">>> Darwin setup"
install_brew
preinstall brew install
system_update
install_git
install_zsh
packages
languages
shell_setup
fonts $HOME/Library/Fonts/
symlink
cleanup brew uninstall
echo "<<< Darwin setup"
