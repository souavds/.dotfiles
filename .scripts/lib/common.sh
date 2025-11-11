#!/usr/bin/env sh

function languages() {
  log ">>> Languages"

  check_and_install mise

  mise use -g node
  KERL_CONFIGURE_OPTIONS="--enable-wx" mise use -g erlang
  mise use -g elixir
  mise reshim

  log "<<< Languages"
}

function shell_setup() {
  log ">>> Shell setup"

  mise use -g usage

  log "<<< Shell setup"
}

function fonts() {
  log ">>> Fonts"

  DEST_FONT_DIR="$1"
  
  check_and_install curl
  check_and_install unzip

  PACKAGES=$(cat ./.scripts/fonts.txt | gum choose --no-limit --header "Which fonts would you like to install?")
  
  for font in $PACKAGES
  do
    FONT_URL=https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip 
    curl -L --create-dirs -O --output-dir ./tmp/fonts/ "$FONT_URL"
    (cd ./tmp/fonts && unzip "$font.zip" -d "$DEST_FONT_DIR$font/")
  done

  log "<<< Fonts"
} 

function install_tmux() {
  log ">>> Tmux"

  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  log "<<< Tmux"
}

function symlink() {
  log ">>> Symlink"

  confirm "Do you want to symlink these dotfiles? (Make sure to backup yours first)" && (stow -D . && stow .)

  log "<<< Symlink"
}
