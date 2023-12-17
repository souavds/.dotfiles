#!/bin/sh

cd "$(dirname "$0")"
export DOTFILES=$(pwd -P)

COMMAND=""

while getopts c: flag
do
    case "${flag}" in
        c) COMMAND=${OPTARG};;
    esac
done

if [$COMMAND == ""]
then
  echo "You need to pass the install command flag (-c 'sudo zypper in -y')"
  exit
fi

function install_shell() {
  echo "Installing fish shell"
  
  $COMMAND fish

  read -p "Do you want to make fish the default shell? (y/n) " yn < /dev/tty

  case $yn in
    [Yy]* ) chsh -s $(which fish) ;;
    [Nn]* ) echo "> Skipped"; return ;;
    * ) echo "> Incorrect option, skipping"; return ;;
  esac

  echo "Finished installing shell"
}

function install_packages() {
  echo "Installing packages"

  find -H "$DOTFILES" -maxdepth 2 -name 'packages' | while read packagesfile
  do
    cat "$packagesfile" | while read line
    do
      echo "Installing package -> $line"
      $COMMAND $line
    done
  done
     
  echo "Finished installing packages"
}


echo "Initiating setup..."
install_shell
echo ""
install_packages
echo ""


