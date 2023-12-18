#!/bin/sh

source $(dirname "$0")/cli/pwd.sh
source $DOTFILES/scripts/cli/colorizer.sh

export INSTALL_CMD=

function get_install_cmd() {
  user INSTALL_CMD -p "What is the install command in your system? (i.e. brew install)"
}
