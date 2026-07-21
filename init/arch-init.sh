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

# --- locale: enable en_US + ko_KR for Korean display/input ---
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo sed -i 's/^#ko_KR.UTF-8 UTF-8/ko_KR.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=en_US.UTF-8

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
stow -v -R zsh nvim tmux yazi lazygit fastfetch opencode sesh wezterm fontconfig

# --- refresh font cache so Windows fonts become visible to WSL apps ---
fc-cache -f -v

# --- WezTerm config symlink on the Windows side (Windows WezTerm reads %USERPROFILE%\.config\wezterm) ---
win_home=$(wslpath "$(powershell.exe -NoProfile -Command 'Write-Output $env:USERPROFILE' | tr -d '\r')")
wezterm_win_dir="$win_home/.config/wezterm"
wezterm_repo_file="$(pwd)/wezterm/.config/wezterm/wezterm.lua"
wezterm_win_link="$wezterm_win_dir/wezterm.lua"

if [ -f "$wezterm_repo_file" ]; then
  mkdir -p "$wezterm_win_dir"

  if [ -e "$wezterm_win_link" ] && [ ! -L "$wezterm_win_link" ]; then
    mv "$wezterm_win_link" "$wezterm_win_link.backup"
  fi

  rm -f "$wezterm_win_link"
  cmd.exe /c "mklink \"$(wslpath -w "$wezterm_win_link")\" \"$(wslpath -w "$wezterm_repo_file")\"" >/dev/null 2>&1 || true
fi

echo
echo "Done. Remaining manual steps:"
echo "  - Copy wsl/wsl.conf  -> /etc/wsl.conf            (sudo; set [user] default)"
echo "  - Copy wsl/.wslconfig -> %UserProfile%\\.wslconfig (Windows side)"
echo "  - Run 'wsl --shutdown' from Windows to apply both, then reopen."
echo "  - Install these fonts in *Windows* (WezTerm reads the Windows font catalog):"
echo "      * 0xProto Nerd Font Mono"
echo "      * Pretendard (or Malgun Gothic as a CJK fallback)"
