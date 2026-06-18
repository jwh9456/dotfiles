#!/usr/bin/env bash
# Copy image file(s) to the Windows clipboard from WSL (bound to `y` in yazi).
# win32yank handles text only, so images are pushed through PowerShell's clipboard API.
set -euo pipefail
for path in "$@"; do
  win=$(wslpath -w "$path")
  powershell.exe -NoProfile -Command \
    "Add-Type -AssemblyName System.Windows.Forms,System.Drawing; [System.Windows.Forms.Clipboard]::SetImage([System.Drawing.Image]::FromFile('$win'))"
done
