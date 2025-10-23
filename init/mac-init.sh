#!/bin/bash

# install stow
brew install stow

# install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install zsh plugins
brew install zsh-syntax-highlighting
brew install zsh-autosuggestions

stow -v -R zsh

# install fzf
brew install fzf

# install zoxide
brew install zoxide

# configure zoxide hooks
echo 'eval "$(zoxide init zsh --hook cd)"' >> ~/.zshrc

