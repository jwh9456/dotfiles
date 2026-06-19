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

# install input method switcher for Neovim
brew tap laishulu/homebrew
brew install macism

# configure zoxide hooks
echo 'eval "$(zoxide init zsh --hook cd)"' >> ~/.zshrc

# configure tmux
stow -v -R tmux

TMUX_CATPPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ -d "$TMUX_CATPPUCCIN_DIR/.git" ]; then
  git -C "$TMUX_CATPPUCCIN_DIR" fetch --tags
  git -C "$TMUX_CATPPUCCIN_DIR" checkout v2.3.0
else
  rm -rf "$TMUX_CATPPUCCIN_DIR"
  git clone -b v2.3.0 https://github.com/catppuccin/tmux.git "$TMUX_CATPPUCCIN_DIR"
fi

# configure sesh (tmux session manager) — fzf + zoxide 기반 세셔나이저
# 프리뷰에 lsd 트리 사용. arch에서는 `yay -S sesh-bin` + `pacman -S lsd`
brew install sesh
brew install lsd
stow -v -R sesh
