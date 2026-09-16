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
| ⏪ **Undotree** visual undo | 🌿 **Fugitive** Git integration |
| 📊 **Lualine** status bar | ✅ Diagnostics panel |

> Snippets are included for **Go, TypeScript/React, C/C++, Rust, Lua, and Python** — type `if`, `for`, `while`, `func` (or `fn`/`function`/`def`) and press `Enter` for a full construct with placeholders you can jump through with `Tab`.

## Requirements

- **Neovim ≥ 0.10** (the installer can auto-install it for you)
- `git`, `curl`, `unzip`
- A terminal emulator that supports TrueColor (e.g. GNOME Terminal, kitty, wezterm)

## Installation

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/moawedmohamed/prime-nvim/main/nvim-prime/install.sh | bash
```

The script:

1. **Installs Neovim** automatically if it's missing or older than 0.10
   (Linux → official release from GitHub; macOS → Homebrew)
2. Downloads this template into `~/.config/nvim-prime`
   (backing up any existing `nvim-prime` config first)
3. Adds a `prime` shell alias and ensures `~/.local/bin` is on your `PATH`
4. Installs all plugins on first start

### Manual installation

```bash
git clone --depth 1 https://github.com/moawedmohamed/prime-nvim.git
cp -r prime-nvim/nvim-prime ~/.config/nvim-prime
# start it once to fetch plugins
NVIM_APPNAME="nvim-prime" nvim "+Lazy sync" +qa
```

### Update

```bash
rm -rf ~/.config/nvim-prime
curl -fsSL https://raw.githubusercontent.com/moawedmohamed/prime-nvim/main/nvim-prime/install.sh | bash
```

## Usage

Launch the template with either:

```bash
prime
```

or

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
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<space> vca` | Code actions |
| `<space> vrn` | Rename symbol |
| `<space> xx` | Diagnostics panel |
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
| `<space> u` | Undo tree |

## Project layout

```
nvim-prime/
├── init.lua              # entry point
├── lazy-lock.json        # pinned plugin versions
├── install.sh            # one-click installer
└── lua/prime/
    ├── set.lua           # options (numbers, tabs, autosave, undo)
    ├── remap.lua         # keymaps  (leader = space)
    ├── lazy.lua          # plugins, LSP, completion, diagnostics
    └── snippets/         # LuaSnip snippets per language
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