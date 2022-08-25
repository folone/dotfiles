#!/bin/sh

sudo xcode-select --install

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update
brew update
brew upgrade

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install all the packages
brew install rg
brew install htop
brew install tig
brew install antigen
brew install gnupg
brew install cmacrae/formulae/spacebar
brew install koekeishiya/formulae/yabai

# Iterm2
brew install --cask iterm2

# Onivim2 editor
export HOMEBREW_ONIVIM_SERIAL=""
brew tap marblenix/onivim2
brew install --cask onivim2

# Install vim pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Set up useful aliases
arc alias lazydiff diff -- --nolint --nounit --excuse "Skipping linting for speed"

# Prompt user to finish the installation
echo 'Finish the installation:'
echo '* https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection'
echo '* create spaces as described in https://support.apple.com/en-gb/guide/mac-help/mh14112/mac'
echo '* make both menu-bar and dock hide in System Settings'
echo '* restart yabai: brew services restart yabai'
# Add more manual steps here
