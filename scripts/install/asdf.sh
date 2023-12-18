#!/bin/sh

function install_asdf() {
  info "Installing asdf"

  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
  mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions;

  sucess "Installed asdf"
}
