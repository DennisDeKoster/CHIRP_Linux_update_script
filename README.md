# CHIRP Auto-Update Script 🚀

[![Bash](https://img.shields.io/badge/language-Bash-89e051?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A simple, fully automated Bash script that keeps your **CHIRP-next** (the daily development builds of CHIRP – the popular amateur radio programming software) always up to date when installed via `pipx`.

### What it does
- Detects your currently installed CHIRP version
- Scrapes the official CHIRP-next archive for the latest daily build
- Downloads the newest `.whl` file only if it’s actually newer
- Uninstalls the old version and installs the new one using `pipx`
- Cleans up the downloaded file (moves to trash or deletes)

Perfect for Linux users who want to stay on the bleeding edge without manual checking.

## Requirements

- Linux (tested on Ubuntu, Fedora, Arch, etc.)
- `pipx` installed and in your `$PATH`
- CHIRP previously installed via `pipx install chirp` (or an earlier run of this script)
- `curl`, `grep`, `sort`, and standard GNU tools
- Internet connection

Optional (for nice trash behavior on GNOME-based desktops):
- `gio` (part of `glib` – usually already installed)

## First-time setup

The first time you run the script, it will automatically detect if `pipx` is missing and offer to install it for you (on Ubuntu, Debian, Fedora, Arch, openSUSE, etc.).

Just answer **y** when asked – everything will be set up automatically!

## Installation

```bash
# 1. Download the script
curl -L -o chirp-update.sh https://github.com/DennisDeKoster/CHIRP_Linux_update_script/blob/main/chirp-update.sh

# 2. Make it executable
chmod +x chirp-update.sh

# 3. (Recommended) Move it to a directory in your PATH
sudo mv chirp-update.sh /usr/local/bin/chirp-update
