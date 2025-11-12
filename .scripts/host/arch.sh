#!/usr/bin/env sh

source ./.scripts/lib/preinstall.sh
source ./.scripts/lib/terminal/tui.sh
source ./.scripts/lib/common.sh
source ./.scripts/lib/cleanup.sh

function pkg() {
  if command -v paru &> /dev/null
  then
    paru $@
  else
    sudo pacman $@
  fi
}

function check_and_install() {
  if ! command -v $1 &> /dev/null
  then
    pkg -S $1
  fi
}

function system_update() {
  log ">>> Update system"

  pkg -Syu --noconfirm

  log "<<< Update system"
}

function install_git() {
  log ">>> Git"

  pkg -S git

  log "<<< Git"
}

function aur_helper() {
  log ">>> Paru"

  pkg -S --needed base-devel
  pkg -S rustup
  rustup default stable
  rm -rf ./tmp/paru
  git clone https://aur.archlinux.org/paru-git.git ./tmp/paru
  (cd ./tmp/paru && makepkg -si)
  rm -rf ./tmp/paru

  log "<<< Paru"
} 

function install_zsh() {
  log ">>> ZSH"
  
  pkg -S zsh

  confirm "Do you want to make zsh the default shell?" &&(chsh -s $(which zsh) && zsh)

  log "<<< ZSH"
}

function packages() {
  log ">>> Packages"

  PACKAGES=$(cat ./.scripts/packages.txt | choose "Which packages would you like to install?")
  pkg -S $PACKAGES

  log "<<< Packages"
}

function arch_packages() {
  log ">>> Arch Packages"

  ARCH_PACKAGES=$(cat ./.scripts/arch_packages.txt | choose "Which packages would you like to install?")
  pkg -S $PACKAGES

  log "<<< Arch Packages"
}

function languages_dependencies() {
  log ">>> Languages dependencies"

  pkg -S jdk-openjdk unixodbc ncurses libssh wxwidgets-gtk3 wxwidgets-common unzip

  log "<<< Languages dependencies"
}

function tlp_setup() {
  log ">>> TLP"

  pkg -S tlp tlp-rdw
  sudo systemctl enable --now tlp.service
  sudo cp ./.cp/tlp.conf /etc/tlp.conf
  sudo systemctl restart tlp.service

  log "<<< TLP"
}

function dms_setup() {
  log ">>> DankMaterialLinux"

  pkg -S dms-shell-bin

  log "<<< DankMaterialLinux"
}

function fingerprint_setup() {
  log ">>> Fingerprint"

  pkg -S fprintd
  fprintd-enroll
  fprintd-verify
  sudo cp ./.cp/pam.d/system-local-login /etc/pam.d/system-local-login

  log "<<< Fingerprint"
}

echo ">>> Archlinux setup"
preinstall sudo pacman -S
system_update
install_git
aur_helper
install_zsh
packages
arch_packages
languages_dependencies
languages
shell_setup
fonts $HOME/.fonts/
install_tmux
tlp_setup
fingerprint_setup
symlink
cleanup sudo pacman -Rsn
echo "<<< Archlinux setup"
