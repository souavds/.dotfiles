#!/bin/sh

INFO_SYMBOL="\uea74"
USER_SYMBOL="\uf420"
SUCCESS_SYMBOL="\uf49e"
FAIL_SYMBOL="\uea87"
USER_INPUT_MARGIN="   "

info () {
  printf "\033[00;34m $INFO_SYMBOL $1 \033[0m\n"
}

user () {
  local read_type=$2 text=$3
  local -n result=$1

  printf "\033[0;33m $USER_SYMBOL $text \033[0m\n"

  case "$read_type" in
    -p ) read -p "$USER_INPUT_MARGIN" result < /dev/tty;;
    -n ) read -n 1 result < /dev/tty;;
    * ) ;;
  esac
}

success () {
  printf "\033[00;32m $SUCCESS_SYMBOL $1 \033[0m\n"
}

fail () {
  printf "\033[0;31m $FAIL_SYMBOL $1 \033[0m\n"
  echo ''
  exit
}
