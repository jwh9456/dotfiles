# WSL host configuration

These files configure WSL2 itself. They are **not stowed** — they live on the
Windows filesystem or in `/etc`, which `stow` can't symlink into `$HOME`. They're
kept here purely for **version history** and copied into place manually.

| File         | Destination                          | Scope            | Needs    |
|--------------|--------------------------------------|------------------|----------|
| `.wslconfig` | `C:\Users\<you>\.wslconfig`          | all WSL2 distros | Windows  |
| `wsl.conf`   | `/etc/wsl.conf` (inside this distro) | this distro      | `sudo`   |

## Apply

```sh
# inside the distro
sudo cp wsl/wsl.conf /etc/wsl.conf          # then edit [user] default=

# copy the Windows-side file (adjust the user path)
cp wsl/.wslconfig "$(wslpath "$(cmd.exe /c 'echo %UserProfile%' 2>/dev/null | tr -d '\r')")/.wslconfig"
```

Then, from **PowerShell/CMD on Windows**:

```powershell
wsl --shutdown
```

Reopen the distro for the changes to take effect.

## What's set

- **`.wslconfig`** — VM-wide: RAM/CPU caps, `networkingMode=mirrored` (shares the
  Windows network stack; needs Win11 22H2+), `autoMemoryReclaim=gradual` (returns
  freed RAM to Windows), `sparseVhd` (auto-shrinks the disk).
- **`wsl.conf`** — per-distro: `systemd=true`, default user, `/mnt` automount
  options, and Windows interop (kept **on** because `win32yank.exe` / `powershell.exe`
  / `wslview` depend on it).

> When you change these on a machine, edit the copy here and commit it so the
> history stays in sync.
