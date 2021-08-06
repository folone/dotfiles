#!/bin/sh

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update
brew update
brew upgrade

# Install all the packages
brew install rg htop tig antigen oh-my-zsh gnupg cmacrae/formulae/spacebar koekeishiya/formulae/yabai

# Install vim pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
