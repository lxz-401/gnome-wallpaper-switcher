# GNOME Wallpaper Switcher

A modular, lightweight, and robust CLI utility and background service for desktop wallpaper management and automated transitions on Arch Linux running the GNOME Desktop Environment.

`gnome-wallpaper-switcher` interfaces directly with GNOME's GSettings schema (`org.gnome.desktop.background picture-uri` and `picture-uri-dark`), providing seamless transitions across both light and dark system appearances. It supports on-demand manual triggers (perfect for keyboard shortcuts) and background automation via systemd user units.

---

## Features

- **Directional & Random Modes (`-m, --mode`):**
  - `forward`: Cycles sequentially through wallpapers (sorted naturally with `sort -V`).
  - `backward`: Cycles backward through wallpapers.
  - `random`: Pseudo-random selection with duplicate-avoidance logic.
- **Undo History (`-u, --undo`):**
  - Maintains a rolling history of the last 50 set wallpapers in `~/.cache/gnome-wallpaper-switcher/history`.
  - Instantly reverts to the previous wallpaper and verifies file integrity before applying.
- **Subdirectory Categorization (`-c, --category`):**
  - Scope transitions to specific subfolders inside your wallpapers collection (e.g., `anime`, `minimal`, `nature`, `dark`).
- **Dynamic Path Override (`-p, --path`):**
  - Override the default wallpapers folder on the fly.
- **Background Daemon (`-d, --daemon`, `-i, --interval`):**
  - Automated continuous cycling at configurable minute intervals.
  - Signal-aware: listens for `SIGUSR1` (instant wallpaper switch), `SIGHUP` (config reload), and `SIGTERM`/`SIGINT` (clean exit).
- **Desktop Notifications (`-n, --notify`):**
  - Native desktop notifications using `notify-send` with wallpaper thumbnail previews.
- **Shell Completions:**
  - Full tab-completion for both **Bash** and **Zsh**, including dynamic wallpaper category auto-completion.
- **Arch Packaging Standards:**
  - Standard `PKGBUILD` and `Makefile` ready for `makepkg` and the Arch User Repository (AUR).

---

## Project Structure

```text
gnome-wallpaper-switcher/
├── PKGBUILD                                # Arch Linux package recipe
├── Makefile                                # Standard UNIX build & install targets
├── .gitignore
├── LICENSE                                 # MIT License
├── README.md                               # Project documentation
├── bin/
│   └── gnome-wallpaper-switcher            # Core modular Bash executable
├── config/
│   └── config.conf.example                 # Default configuration template
├── systemd/
│   └── gnome-wallpaper-switcher.service    # Systemd user service unit
└── completions/
    ├── bash/
    │   └── gnome-wallpaper-switcher        # Bash programmable completion
    └── zsh/
        └── _gnome-wallpaper-switcher       # Zsh completion definition
```

---

## Installation

### Method 1: Arch Linux Package (`makepkg`)

Clone the repository and build the Arch package using `makepkg`:

```bash
git clone https://github.com/lxz/gnome-wallpaper-switcher.git
cd gnome-wallpaper-switcher
makepkg -si
```

This installs:
- Binary: `/usr/bin/gnome-wallpaper-switcher`
- Systemd unit: `/usr/lib/systemd/user/gnome-wallpaper-switcher.service`
- Completions: `/usr/share/bash-completion/completions/` and `/usr/share/zsh/site-functions/`
- Documentation & Config example: `/usr/share/doc/gnome-wallpaper-switcher/`

### Method 2: Manual Installation (`make`)

You can install directly using the `Makefile`:

```bash
# System-wide installation (default: /usr)
sudo make install

# Or local user installation:
make install PREFIX="$HOME/.local"
```

To uninstall:
```bash
sudo make uninstall
```

---

## Configuration

Copy the example configuration file to your user config directory:

```bash
mkdir -p ~/.config/gnome-wallpaper-switcher
cp config/config.conf.example ~/.config/gnome-wallpaper-switcher/config.conf
```

### `config.conf` Options:

```bash
# Base directory containing wallpapers
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"

# Default mode: forward, backward, random
MODE="forward"

# Default category subfolder inside WALLPAPERS_DIR (leave empty for all)
CATEGORY=""

# Automatic switching interval in minutes (daemon mode)
INTERVAL=15

# Desktop notifications via notify-send (true/false)
NOTIFY=false
```

---

## CLI Usage

### Basic Commands

```bash
# Switch to the next wallpaper (forward)
gnome-wallpaper-switcher

# Switch to the previous wallpaper (backward)
gnome-wallpaper-switcher --mode backward

# Select a random wallpaper
gnome-wallpaper-switcher --mode random

# Undo / restore previous wallpaper
gnome-wallpaper-switcher --undo

# Inspect currently active wallpaper
gnome-wallpaper-switcher --current

# List all discovered wallpapers in the active folder
gnome-wallpaper-switcher --list
```

### Scoping to Categories & Custom Directories

```bash
# Target the 'arch-wallpapers' subdirectory inside ~/Pictures/Wallpapers
gnome-wallpaper-switcher --category arch-wallpapers

# Specify an entirely separate directory
gnome-wallpaper-switcher --path ~/Downloads/Wallpapers --mode random

# Send a desktop notification on change
gnome-wallpaper-switcher --notify
```

---

## Systemd Daemon Service

Run the switcher as a persistent background daemon managed by your systemd user session:

### 1. Enable and Start the Service

```bash
systemctl --user daemon-reload
systemctl --user enable --now gnome-wallpaper-switcher.service
```

### 2. Check Service Status & Logs

```bash
systemctl --user status gnome-wallpaper-switcher.service
journalctl --user -u gnome-wallpaper-switcher.service -f
```

### 3. Send Signals to the Running Daemon

You can interact with the running daemon without restarting it:

- **Trigger immediate wallpaper transition:**
  ```bash
  killall -SIGUSR1 gnome-wallpaper-switcher
  ```

- **Reload configuration after modifying `config.conf`:**
  ```bash
  killall -SIGHUP gnome-wallpaper-switcher
  ```

---

## GNOME Keyboard Shortcuts Integration

Bind quick switcher actions to global hotkeys in GNOME:

1. Open **Settings** → **Keyboard** → **View and Customize Shortcuts** → **Custom Shortcuts**.
2. Click **+** (Add Shortcut) and configure:

| Shortcut Name | Command | Suggested Keybinding |
|---|---|---|
| **Wallpaper: Next** | `gnome-wallpaper-switcher -m forward` | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>→</kbd> |
| **Wallpaper: Previous** | `gnome-wallpaper-switcher -m backward` | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>←</kbd> |
| **Wallpaper: Random** | `gnome-wallpaper-switcher -m random` | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>R</kbd> |
| **Wallpaper: Undo** | `gnome-wallpaper-switcher --undo` | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>Z</kbd> |

---

## Supported Image Formats

- `.jpg`, `.jpeg`
- `.png`
- `.webp`
- `.jxl`
- `.svg`
- `.bmp`

---

## License

Distributed under the [MIT License](LICENSE).
