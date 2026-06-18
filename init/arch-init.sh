#!/bin/bash
# WSL2 Arch Linux bootstrap for these dotfiles.
# Run once after cloning the repo and `cd`-ing into it.
set -e

# --- yay (AUR helper) ---
if ! command -v yay >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm git base-devel
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

# --- packages (WSL CLI subset; see pkglist.txt) ---
yay -S --needed --noconfirm $(cat pkglist.txt)

# --- oh-my-zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- win32yank: clipboard bridge for nvim/yazi <-> Windows ---
if ! command -v win32yank.exe >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  tmp=$(mktemp -d)
  curl -fsSLo "$tmp/win32yank.zip" \
    https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
  unzip -p "$tmp/win32yank.zip" win32yank.exe > "$HOME/.local/bin/win32yank.exe"
  chmod +x "$HOME/.local/bin/win32yank.exe"
  rm -rf "$tmp"
fi

# --- sdkman (JDK / build-tool version manager) ---
# After install:  sdk install java 21.0.x-tem   (then `sdk default java 21.0.x-tem`)
if [ ! -d "$HOME/.sdkman" ]; then
  curl -s "https://get.sdkman.io" | bash
fi

# --- stow the dotfiles (DE/WM and wsl/ are intentionally excluded) ---
stow -v -R zsh nvim tmux yazi lazygit fastfetch opencode

echo
echo "Done. Remaining manual steps:"
echo "  - Copy wsl/wsl.conf  -> /etc/wsl.conf            (sudo; set [user] default)"
echo "  - Copy wsl/.wslconfig -> %UserProfile%\\.wslconfig (Windows side)"
echo "  - Run 'wsl --shutdown' from Windows to apply both, then reopen."
echo "  - Set a Nerd Font in your Windows terminal for the agnoster prompt glyphs."
