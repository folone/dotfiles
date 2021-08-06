#!/bin/sh

sudo xcode-select --install

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update
brew update
brew upgrade

# Install all the packages
brew install rg htop tig antigen oh-my-zsh gnupg cmacrae/formulae/spacebar koekeishiya/formulae/yabai

# Iterm2
brew install --cask iterm2

# Onivim2 editor
brew tap marblenix/onivim2
brew install --cask onivim2


# Install vim pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
