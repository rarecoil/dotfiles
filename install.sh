#!/bin/bash
# bootstrap this machine with preferred tools
# shellcheck disable=SC1090

cd "$(dirname "$0")" || exit 1
DOTFILES_DIR = "$(dirname "$0")"


if [ "$(id -u)" = 0 ]; then
    echo "This script is not to be run as root."
    exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    # install homebrew if not
    if ! [ -x "$(command -v brew)" ]; then
        echo "Installing Homebrew"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    # now, install things we need
    brew install coreutils go node python ruby

    if ! [ -h "$HOME/.profile" ]; then
      ln -s "$DOTFILES_DIR/.profile" "$HOME/.profile"
    fi
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    DISTRO=""
    if [ -x "$(command -v pacman)" ]; then
        DISTRO="arch"
    elif [ -x "$(command -v apt)" ]; then
        DISTRO="debian"
    else
        echo "This is an unsupported platform."
        exit 1
    fi

    if [ "$DISTRO" == "arch" ]; then
        sudo pacman -Syu
        sudo pacman -S curl vim nodejs npm go ruby python3 base-devel git
    elif [ "$DISTRO" == "debian" ]; then
        sudo apt-get update
        sudo apt-get install -y curl vim
        curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
        sudo apt-get install -y nodejs ruby golang build-essential git-core
    fi

    if [ -f "$HOME/.bashrc" ]; then
        mv "$HOME/.bashrc" "$HOME/.bashrc.old"
    fi

    if ! [ -h "$HOME/.bashrc" ]; then
      ln -s "$DOTFILES_DIR/profile" "$HOME/.bashrc"
    fi
fi

# cross-platform fun

# powerline-go
go get -u github.com/justjanne/powerline-go

# janus / vim
curl -L https://bit.ly/janus-bootstrap | bash
if ! [-h "$HOME/.vimrc.after" ]; then
    ln -s ./.dotfiles/vimrc.after "$HOME/.vimrc.after"
fi

# generate ssh key
if ! [ -f "$HOME/.ssh/id_ed25519" ]; then
    echo "No SSH key found, generating SSH key."
    ssh-keygen -t ed25519 -C "rarecoil@$(hostname | cut -d\".\" -f1)"
fi

echo "Complete."
# source our new shell scripts
if [[ "$OSTYPE" == "darwin"* ]]; then
    source "$HOME/.profile"
else
    source "$HOME/.bashrc"
fi
