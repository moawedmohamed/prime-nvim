<div align="center">

# 🔷 prime-nvim

**A modern, VS Code–flavored Neovim template — inspired by The Primeagen.**

![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?logo=neovim&logoColor=white&labelColor=000)
![Lua](https://img.shields.io/badge/Lua-100%25-2C2D72?logo=lua&logoColor=white&labelColor=000)
![lazy.nvim](https://img.shields.io/badge/plugin%20manager-lazy.nvim-5391FE?labelColor=000)
![License](https://img.shields.io/badge/license-MIT-57A143?labelColor=000)

*Works side-by-side with your existing Neovim config. Nothing is overwritten.*

</div>

---

## What is this?

`prime-nvim` is a **fully isolated Neovim configuration** that lives in its own
directory (`~/.config/nvim-prime`). It runs **alongside** your normal `nvim`
setup — you pick which one to launch — so you can try a modern, curated
experience without touching a single file of your current config.

It bundles everything you need out of the box:

| | |
|---|---|
| 🎨 **rose-pine** theme (moon variant) | ✨ **Treesitter** syntax highlighting |
| 🚀 **lazy.nvim** plugin manager | 🧠 **lsp-zero v3** + **Mason** LSP servers |
| ⚡ **nvim-cmp** autocompletion | 🔤 **LuaSnip** code snippets |
| 🔎 **Telescope** fuzzy finder | 📍 **Harpoon** quick file marks |
| ⏪ **Undotree** visual undo | 🌿 **Fugitive** + **gitsigns** Git |
| 📊 **Lualine** status bar | ✅ Inline diagnostics + signs |
| 💬 **Comment.nvim** (`gcc`) | ⌨️ **which-key** key hints |
| 🔄 One-command `prime update` | 🔔 Update-available warning |

> Snippets are included for **Go, TypeScript/React, C/C++, Rust, Lua, and Python** — type `if`, `for`, `while`, `func` (or `fn`/`function`/`def`) and press `Enter` for a full construct with placeholders you can jump through with `Tab`.

## Requirements

- **Neovim ≥ 0.10** (the installer can auto-install it for you)
- `git`, `curl`, `unzip`
- A terminal emulator that supports TrueColor (e.g. GNOME Terminal, kitty, wezterm)

> **Remote / headless machines:** the clipboard works there too — see
> [Clipboard](#clipboard) below. No extra setup required.

## Installation

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/moawedmohamed/prime-nvim/main/install.sh | bash
```

The script:

1. **Installs Neovim** automatically if it's missing or older than 0.10
   (Linux → official release from GitHub; macOS → Homebrew)
2. **`git clone`s** this template into `~/.config/nvim-prime`
   (backing up any existing `nvim-prime` config first)
3. Installs the `prime` launcher into `~/.local/bin` and ensures it's on your `PATH`
4. Installs all plugins on first start

Because the config directory is a real git checkout, `prime update` can pull
future changes **without wiping your own edits**.

### Manual installation

```bash
git clone https://github.com/moawedmohamed/prime-nvim.git ~/.config/nvim-prime
ln -sf ~/.config/nvim-prime/bin/prime ~/.local/bin/prime   # ensure ~/.local/bin is on PATH
# start it once to fetch plugins
NVIM_APPNAME="nvim-prime" nvim "+Lazy! sync" +qa
```

### Update

```bash
prime update        # git pull + plugin sync
```

`prime update` fast-forwards `~/.config/nvim-prime` to the latest `main`, then
runs `:Lazy sync` for you. If you have local edits, commit them first (or use
`git -C ~/.config/nvim-prime pull --rebase`) so the fast-forward applies cleanly.

**Update warnings** — when a newer version is published, `prime-nvim` notices on
startup and warns:

```
prime-nvim update available: 1.1.0 -> 1.2.0
Run `prime update` (or :PrimeUpdate) to upgrade.
```

The check is async, has a short timeout, and runs at most once a day. Disable it
with `export PRIME_NO_UPDATE_CHECK=1`. You can also update from inside Neovim
with `:PrimeUpdate` and check the current build with `:PrimeVersion`.

## Usage

Launch the template with `prime`:

```bash
prime                 # launch the template (leader = Space)
prime update          # pull the latest template + sync plugins
prime version         # print the installed version
prime doctor          # show paths + git state (handy in bug reports)
prime help            # show all commands
```

Without the launcher it's just:

```bash
NVIM_APPNAME="nvim-prime" nvim
```

Your regular `nvim` command remains completely untouched.

<details>
<summary><strong>⚠️ Troubleshooting</strong> — plugins or LSP servers not loading</summary>

Sometimes picky network connections break the first plugin install:

```bash
NVIM_APPNAME="nvim-prime" nvim --headless "+Lazy sync" +qa
```

Servers are installed via Mason. Run `:Mason` inside the template, press <kbd>i</kbd>,
and install the server you need for each language (gopls, lua-language-server,
rust-analyzer, typescript-language-server, ...).
</details>

## Clipboard

The editing keymaps (`<C-c>`, `<C-x>`, `<C-v>`, `<space> y`, `<space> Y`) all target
the `"+` register, so they need a working system clipboard. `prime-nvim` picks a
provider automatically at startup:

| Environment | Provider | How it works |
|---|---|---|
| Wayland | `wl-clipboard` | native |
| X11 with `xclip`/`xsel` | `xclip` | native |
| **No display server** (SSH box, container, headless VM) | **OSC 52** | nvim base64-encodes the text into an escape sequence; your **local** terminal writes it to your real desktop clipboard |

Run `:PrimeClipboard` to see which one is active and why.

<details>
<summary><strong>Why this needs special handling</strong></summary>

On a machine with no X11 and no Wayland, `xclip`/`wl-copy` cannot reach any display
server, and Neovim fails **silently** — the keymaps look like they work, the text just
never leaves Neovim. That is the most confusing nvim-on-a-remote bug there is, because
nothing errors.

Two caveats for the OSC 52 path:

- **tmux must be ≥ 3.2.** Older tmux swallows the sequence. Either run nvim outside
  tmux, or upgrade tmux and add `set -g set-clipboard on` to your `tmux.conf`.
  `:PrimeClipboard` warns you when this applies.
- **Pasting** (`"+p`) needs a terminal that allows OSC 52 *reads*, which many block by
  default. Yanking always works; if `"+p` comes up empty, use your terminal's own
  `Ctrl+Shift+V`.
</details>

## Keybindings

`<leader>` = **`Space`**

### Files & navigation
| Keys | Action |
|---|---|
| `<space> pf` | Find files (Telescope) |
| `<C-p>` | Git files (Telescope) |
| `<space> ps` | Grep / search text |
| `<space> pv` | Browse files (netrw) |
| `<C-z>` / `<C-t>` | Jump back / forward to last positions |
| `<C-^>` | Toggle to the previously edited file |

### Harpoon (quick marks)
| Keys | Action |
|---|---|
| `<space> a` | Mark the current file |
| `<C-e>` | Open the mark list |
| `<C-h>` `<C-l>` `<C-n>` `<C-s>` | Jump to mark 1 / 2 / 3 / 4 |

### Editing (VS Code style)
| Keys | Action |
|---|---|
| `Alt+↑` / `Alt+↓` (or `Alt+K` / `Alt+J`) | Move line / selection up or down |
| `Ctrl+C` / `Ctrl+X` / `Ctrl+V` *(visual/insert)* | Copy / cut / paste to the system clipboard |
| `<space> y` / `<space> Y` | Yank to the system clipboard |
| `<space> d` | Delete without clobbering the register |
| `<space> s` | Replace all occurrences of the word under the cursor |
| `<space> f` | Format the buffer (LSP) |
| `Ctrl+Z` / `Ctrl+T` *(insert/visual)* | Undo / redo your position history |
| `Backspace` / `Ctrl+W` | Delete the whole word (like VS Code) |

### Code intelligence
| Keys | Action |
|---|---|
| `gd` / `gD` | Go to definition / declaration |
| `gi` / `go` | Go to implementation / type definition |
| `gr` | References |
| `gK` | Signature help |
| `K` | Hover documentation |
| `<space> ds` / `<space> ws` | Document / workspace symbols |
| `<space> vca` | Code actions |
| `<space> vrn` | Rename symbol |
| `gj` / `gk` | Next / previous diagnostic |
| `<space> cd` | Diagnostic under cursor (float) |
| `<space> xx` | Diagnostics panel |
| `<C-o>` / `<C-z>` | Jump back from definition |
| `<C-k>` `<C-j>` | Next / previous quickfix |
| `<space> k` `<space> j` | Next / previous location list |

### Completion & snippets
- Start typing a trigger word (`if`, `for`, `while`, `func`, `fn`, `def` ...) and press **`Enter`** to expand a full snippet.
- **`Tab`** / **`Shift+Tab`** — navigate snippet placeholders (or completion items).
- **`Ctrl+Space`** — force the completion menu.

### Git & undo
| Keys | Action |
|---|---|
| `<space> gs` | Git status (Fugitive) |
| `<space> hn` / `<space> hp` | Next / previous git hunk |
| `<space> hv` | Preview hunk |
| `<space> hs` / `<space> hr` | Stage / reset hunk |
| `<space> hu` | Undo last stage |
| `<space> hb` | Blame line |
| `<space> hd` | Diff this file |
| `<space> u` | Undo tree |

> The vertical bar in the sign column is **gitsigns** — added/changed/deleted
> lines relative to the last commit. Stage a single change with `<space> hs`, or
> select several files in the `:Git` status window (`<space> gs`) with `V` and
> press `s`, then `cc` to commit.

## Project layout

```
prime-nvim/                 # cloned to ~/.config/nvim-prime
├── init.lua                # entry point
├── VERSION                 # semver, drives the update warning
├── lazy-lock.json          # pinned plugin versions
├── install.sh              # one-click installer
├── bin/prime               # launcher + `prime update`
└── lua/prime/
    ├── clipboard.lua       # clipboard provider (native or OSC 52 on headless)
    ├── update.lua          # update check + :PrimeUpdate / :PrimeVersion
    ├── set.lua             # options (numbers, tabs, autosave, undo)
    ├── remap.lua           # keymaps  (leader = space)
    ├── lazy.lua            # plugins, LSP, completion, diagnostics
    └── snippets/           # LuaSnip snippets per language
        ├── go.lua  typescript.lua  typescriptreact.lua
        ├── c.lua   cpp.lua  rust.lua  lua.lua  python.lua
```

## Extending / contributing

- **Add a snippet:** copy `lua/prime/snippets/go.lua` and swap the triggers/text.
- **Add a plugin:** `lazy.nvim` installs everything declared in `lua/prime/lazy.lua`.
- Config lives entirely under `~/.config/nvim-prime` — back it up, fork it, or just
  share it. PRs are welcome on the [repository](https://github.com/moawedmohamed/prime-nvim).

## License

MIT — do whatever you like with it. Star ⭐ the repo if the template is useful to you!