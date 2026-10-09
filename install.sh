#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/moawedmohamed/prime-nvim.git}"
CONFIG_DIR="${PRIME_CONFIG_DIR:-$HOME/.config/nvim-prime}"
LOCAL_BIN="$HOME/.local/bin"

echo "== Prime template installer =="

require() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "ABORT: '$1' is not installed."
        case "$1" in
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

nvim_version() {
    if command -v nvim >/dev/null 2>&1; then
        nvim --version | head -1 | sed -E 's/^NVIM v//'
    fi
}

have_good_nvim() {
    local v
    v="$(nvim_version)"
    [ -n "$v" ] && printf '%s\n' "$v" "0.10.0" | sort -V | head -1 | grep -qx "0.10.0"
}

ensure_nvim() {
    if have_good_nvim; then
        echo "  Neovim: $(nvim --version | head -1) (OK)"
        return 0
    fi

    if command -v nvim >/dev/null 2>&1; then
        echo "  Found old Neovim: $(nvim --version | head -1) (< 0.10). Upgrading..."
    else
        echo "  Neovim not found. Installing..."
    fi

    case "$(uname -s)" in
        Darwin)
            if command -v brew >/dev/null 2>&1; then
                echo "  Installing via Homebrew..."
                brew install neovim
            else
                echo "ABORT: install Homebrew first (https://brew.sh) or install Neovim manually."
                exit 1
            fi
            ;;
        Linux)
            local arch asset
            case "$(uname -m)" in
                x86_64|amd64) arch="x86_64" ;;
                aarch64|arm64) arch="arm64" ;;
                *) echo "ABORT: unsupported architecture: $(uname -m). Install Neovim manually."; exit 1 ;;
            esac
            asset="nvim-linux-${arch}.tar.gz"
            echo "  Downloading $asset from GitHub (latest release)..."
            curl -fL -o "$TMP/nvim.tar.gz" \
                "https://github.com/neovim/neovim/releases/latest/download/$asset"
            mkdir -p "$HOME/.local/opt"
            tar -C "$HOME/.local/opt" -xzf "$TMP/nvim.tar.gz"
            mkdir -p "$LOCAL_BIN"
            rm -f "$LOCAL_BIN/nvim"
            ln -sf "$HOME/.local/opt"/nvim-linux-*/bin/nvim "$LOCAL_BIN/nvim"
            echo "  Installed Neovim to $LOCAL_BIN/nvim"
            ;;
        *)
            echo "ABORT: unsupported OS ($(uname -s)). Install Neovim >= 0.10 manually."
            exit 1
            ;;
    esac

    if ! have_good_nvim; then
        echo "ABORT: Neovim install failed or still too old."
        exit 1
    fi
    echo "  Neovim: $(nvim --version | head -1) (OK)"
}

echo "[0/4] Making sure Neovim is installed..."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
ensure_nvim

echo "[1/4] Backing up any existing config..."
if [ -d "$CONFIG_DIR" ]; then
    BACKUP="$CONFIG_DIR.backup-$(date +%Y%m%d-%H%M%S)"
    mv "$CONFIG_DIR" "$BACKUP"
    echo "  backed up to $BACKUP"
fi

echo "[2/4] Downloading prime template (git clone)..."
mkdir -p "$(dirname "$CONFIG_DIR")"
git clone "$REPO_URL" "$CONFIG_DIR"
echo "  installed to $CONFIG_DIR"

echo "[3/4] Installing 'prime' launcher and PATH entry..."
mkdir -p "$LOCAL_BIN"
ln -sf "$CONFIG_DIR/bin/prime" "$LOCAL_BIN/prime"
chmod +x "$CONFIG_DIR/bin/prime" "$LOCAL_BIN/prime"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    if [ "$LOCAL_BIN" != "/usr/local/bin" ] && [ "$LOCAL_BIN" != "/usr/bin" ]; then
        if ! grep -qs "PATH=.*$HOME/.local/bin" "$rc"; then
            printf '%s\n' 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
            echo "  PATH entry added to $rc"
        fi
    fi
    if grep -qs 'alias prime=' "$rc"; then
        sed -i.bak '/alias prime=/d' "$rc" && rm -f "$rc.bak"
        echo "  removed old 'alias prime=' from $rc (a launcher script is used now)"
    fi
done

echo "[4/4] Installing plugins on first start (one-time, may take a while)..."
if [ "${PRIME_SKIP_PLUGINS:-}" != "1" ]; then
    NVIM_APPNAME="nvim-prime" nvim --headless "+Lazy! sync" +qa || true
    echo "  plugins installed"
fi

echo
echo "Done! Start your template with:  prime"
echo "Update it later with:            prime update"
