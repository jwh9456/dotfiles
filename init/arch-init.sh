#!/bin/bash

# install stow
yay -S --noconfirm stow

# install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install zsh plugins
yay -S --noconfirm zsh-syntax-highlighting
yay -S --noconfirm zsh-autosuggestions

stow -v -R zsh

# install fzf
yay -S --noconfirm fzf

# install zoxide
yay -S --noconfirm zoxide

# configure zoxide hooks
echo 'eval "$(zoxide init zsh --hook cd)"' >> ~/.zshrc

