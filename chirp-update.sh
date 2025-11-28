#!/bin/bash
# ------------------------------------------------------
# CHIRP auto-update script
# By Dennis de Koster
# ------------------------------------------------------

# --------------------------------------------------
# Check for pipx and offer to install it if missing
# --------------------------------------------------
#!/bin/bash
# CHIRP Auto-Update Script - pipx check (schoon en getest)

# Check if pipx is available
if ! command -v pipx >/dev/null 2>&1; then
    echo "pipx not found – this script needs pipx to manage CHIRP."
    echo
    echo "pipx keeps Python apps like CHIRP nicely isolated."
    echo
    read -p "Install pipx automatically? (y/N): " -n 1 -r reply
    echo
    if [[ $reply =~ ^[Yy]$ ]]; then
        echo "Installing pipx..."
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y pipx
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y pipx
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -Syu --noconfirm pipx
        elif command -v zypper >/dev/null 2>&1; then
            sudo zypper install -y pipx
        else
            echo "Unsupported package manager."
            echo "Install manually with:"
            echo "python3 -m pip install --user pipx"
            echo "python3 -m pipx ensurepath"
            exit 1
        fi
        export PATH="$HOME/.local/bin:$PATH"
        echo "pipx installed!"
    else
        echo "pipx is required. Aborting."
        exit 1
    fi
fi

# Ensure pipx is in PATH for this session
export PATH="$HOME/.local/bin:$PATH"

DOWNLOAD_DIR="$HOME/Downloads"
BASE_URL="https://archive.chirpmyradio.com/chirp_next"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"
echo
echo "CHIRP Auto-Update Script"
echo
# --------------------------------------------------
# 1. Check installed version
# --------------------------------------------------
echo "Checking current version..."
CURRENT_VERSION=$(chirp --version 2>/dev/null | grep -o 'next-[0-9]\{8\}' || echo "none")
if [[ "$CURRENT_VERSION" == "none" ]]; then
    echo "❌ CHIRP not installed (or not found)"
    CURRENT_VERSION=""
else
    echo "✅ Installed: $CURRENT_VERSION"
fi
echo
# --------------------------------------------------
# 2. Check for newest available version
# --------------------------------------------------
echo "Searching on the website for the latest version..."
LATEST_DIR=$(curl -s "$BASE_URL/" -A "$USER_AGENT" | \
    grep -o 'next-[0-9]\{8\}/' | \
    sort -r | \
    head -n 1)
if [[ -z "$LATEST_DIR" ]]; then
    echo "❌ Error: No folder found in $BASE_URL"
    echo
    exit 1
fi
LATEST_DIR_URL="${BASE_URL}/${LATEST_DIR}"
LATEST_DATE=$(echo "$LATEST_DIR" | grep -o '[0-9]\{8\}')
echo "ℹ️ Latest build: next-$LATEST_DATE"
# --------------------------------------------------
# 3. Find .whl file
# --------------------------------------------------
WHL_FILE=$(curl -s "$LATEST_DIR_URL" -A "$USER_AGENT" | \
    grep -o 'chirp-[0-9]\{8\}-py3-none-any\.whl' | \
    head -n 1)
if [[ -z "$WHL_FILE" ]]; then
    echo "❌ Error: Could not find .whl on the website."
    echo
    exit 1
fi
WHL_URL="${LATEST_DIR_URL}${WHL_FILE}"
LOCAL_WHL="$DOWNLOAD_DIR/$WHL_FILE"
REMOTE_DATE=$(echo "$WHL_FILE" | grep -o '[0-9]\{8\}' | head -n1)
echo
# --------------------------------------------------
# 4.Compare versions
# --------------------------------------------------
CURRENT_DATE=$(echo "$CURRENT_VERSION" | grep -o '[0-9]\{8\}')
if [[ "$CURRENT_DATE" == "$REMOTE_DATE" ]]; then
    echo "👍 CHIRP is up-to-date! 👍"
    echo
    exit 0
fi
echo "☝  Update available! ☝"
echo "From next-$CURRENT_DATE to next-$REMOTE_DATE"
echo
# --------------------------------------------------
# 5. Downloading
# --------------------------------------------------
echo "Downloading new version..."
[[ -f "$LOCAL_WHL" ]] && rm -f "$LOCAL_WHL"
curl -L -A "$USER_AGENT" -o "$LOCAL_WHL" "$WHL_URL" > /dev/null 2>&1
if [[ ! -f "$LOCAL_WHL" ]]; then
    echo "❌ Error: Download failed"
    echo
    exit 1
fi
echo "✅ Downloaded: $WHL_FILE"
echo
# --------------------------------------------------
# 6. Uninstall current version
# --------------------------------------------------
echo "Uninstalling current version..."
pipx uninstall chirp
echo
# --------------------------------------------------
# 7. Install new version
# --------------------------------------------------
echo "Installing new version..."
pipx install --system-site-packages "$LOCAL_WHL"
if [[ $? -eq 0 ]]; then
    echo
    echo "✅ CHIRP succesfully updated to next-$REMOTE_DATE!"
    echo
    # Cleanup
    if command -v gio >/dev/null 2>&1; then
        gio trash "$LOCAL_WHL" 2>/dev/null && echo "🗑️  $WHL_FILE moved to trash"
    else
        rm -f "$LOCAL_WHL" && echo "🗑️  $WHL_FILE deleted"
    fi
else
    echo
    echo "❌ Installation failed!"
    echo
    exit 1
fi
echo
