#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/moawedmohamed/my-cli-go.git}"
CONFIG_DIR="${PRIME_CONFIG_DIR:-$HOME/.config/nvim-prime}"

echo "== Prime template installer =="

require() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "ABORT: '$1' is not installed."
        case "$1" in
            nvim) echo "Install Neovim >= 0.10 first (https://github.com/neovim/neovim/releases)." ;;
            git) echo "Install git first." ;;
            unzip) echo "Install unzip first (needed by the plugin manager)." ;;
            curl) echo "Install curl first." ;;
        esac
        exit 1
    }
}

require git
require unzip
require curl
require nvim

NV_VERSION="$(nvim --version | head -1 | sed -E 's/^NVIM v//')"
if [ -z "$NV_VERSION" ] || ! printf '%s\n' "$NV_VERSION" "0.10.0" | sort -V | head -1 | grep -qx "0.10.0"; then
    echo "ABORT: Neovim >= 0.10 required (found: $(nvim --version | head -1))."
    exit 1
fi
echo "  Neovim: $(nvim --version | head -1)"
echo "  Target: $CONFIG_DIR"

echo "[1/4] Downloading prime template..."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 "$REPO_URL" "$TMP/repo" 2>/dev/null || {
    echo "ABORT: failed to clone $REPO_URL (offline or wrong URL?)."
    exit 1
}

echo "[2/4] Backing up any existing config..."
if [ -d "$CONFIG_DIR" ]; then
    BACKUP="$CONFIG_DIR.backup-$(date +%Y%m%d-%H%M%S)"
    mv "$CONFIG_DIR" "$BACKUP"
    echo "  backed up to $BACKUP"
fi

echo "[3/4] Installing config..."
[ -n "$CONFIG_DIR" ] || { echo "ABORT: empty install target."; exit 1; }
mkdir -p "$(dirname "$CONFIG_DIR")"
cp -r "$TMP/repo/nvim-prime" "$CONFIG_DIR"
echo "  installed to $CONFIG_DIR"

echo "[4/4] Adding 'prime' alias..."
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ]; then
        if ! grep -qs 'alias prime=' "$rc"; then
            printf '%s\n' 'alias prime='"'"'NVIM_APPNAME="nvim-prime" nvim'"'"'' >> "$rc"
            echo "  alias added to $rc (open a new terminal or run: source $rc)"
        fi
    fi
done

if [ "${PRIME_SKIP_PLUGINS:-}" != "1" ]; then
    echo "[done] Installing plugins on first start (one-time, may take a while)..."
    nvim --headless "+Lazy sync" +qa || true
    echo "  plugins installed"
fi

echo
echo "Done! Start your template with:"
echo "    prime"
echo "or"
echo "    NVIM_APPNAME=nvim-prime nvim"