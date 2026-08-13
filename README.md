# Neovim setup (Raspberry Pi)

Leader key is **Space**. Press `<Space>` and pause — which-key shows what's available.

## Layout

```
~/.config/nvim/
  init.lua                 options + keymaps + plugin bootstrap
  lua/config/options.lua   editor settings, clipboard
  lua/config/keymaps.lua   global keymaps
  lua/config/lazy.lua      plugin manager bootstrap
  lua/plugins/*.lua        one file per concern; add a file to add plugins
```

## Keymaps

### Files & navigation

| Key                     | Action                               |
| ----------------------- | ------------------------------------ |
| `-`                     | Open parent directory (oil)          |
| `Ctrl-b`                | Toggle explorer in a floating window |
| `<leader>o`             | Open explorer at project root        |
| `Ctrl-p` / `<leader>ff` | Find files                           |
| `<leader>fg`            | Grep across project                  |
| `<leader>fw`            | Grep word under cursor               |
| `<leader>fr`            | Recent files                         |
| `<leader><leader>`      | Switch buffer                        |
| `<leader>fR`            | Project-wide search & replace        |
| `Shift-h` / `Shift-l`   | Previous / next buffer               |
| `<leader>bd`            | Close buffer                         |
| `Ctrl-h/j/k/l`          | Move between splits                  |

### File explorer (oil.nvim)

Directories open as **editable buffers** — you manipulate files with normal Vim
editing, then `:w` to apply. Nothing happens on disk until you write.

| Key     | Action                                        |
| ------- | --------------------------------------------- |
| `-`     | Go up to parent directory                     |
| `<CR>`  | Open file / enter directory                   |
| `<C-r>` | Refresh listing                               |
| `gd`    | Toggle detail view (permissions, size, mtime) |
| `g?`    | Show all oil keymaps                          |
| `q`     | Close                                         |

To act on files, just edit the text: change a name to **rename**, `dd` to
**delete**, `o` and type a name to **create** (end with `/` to make a
directory), `yy`/`p` to **copy**. Then `:w`. A confirmation dialog lists exactly
what will happen before anything is applied — deletes are permanent, since
there's no trash-cli on this box.

`nvim .` or `nvim some/dir` opens oil directly. Netrw is disabled so oil owns
directories.

### Code (LSP)

| Key          | Action                                         |
| ------------ | ---------------------------------------------- |
| `gd`         | Go to definition                               |
| `gr`         | References                                     |
| `K`          | Hover docs                                     |
| `<leader>cr` | Rename symbol                                  |
| `<leader>ca` | Code action                                    |
| `<leader>cf` | Format buffer (prettier/stylua/ruff, else LSP) |
| `<leader>cl` | ESLint fix all (JS/TS buffers)                 |
| `<leader>cs` | Document symbols                               |
| `<leader>e`  | Show line diagnostic                           |
| `<leader>xx` | Diagnostics panel                              |

### Git

| Key                                        | Action                                                 |
| ------------------------------------------ | ------------------------------------------------------ |
| `<leader>gg`                               | **lazygit** (full TUI — stage, commit, branch, rebase) |
| `]h` / `[h`                                | Next / previous change hunk                            |
| `<leader>gp`                               | Preview hunk                                           |
| `<leader>gS`                               | Stage hunk                                             |
| `<leader>gr`                               | Reset hunk                                             |
| `<leader>gd`                               | Diff current file                                      |
| `<leader>gB`                               | Toggle inline blame                                    |
| `<leader>gs` / `<leader>gc` / `<leader>gb` | Telescope status / commits / branches                  |

### Editing

| Key               | Action                 |
| ----------------- | ---------------------- |
| `Ctrl-s`          | Save                   |
| `gcc` / `Ctrl-/`  | Toggle comment         |
| `Alt-j` / `Alt-k` | Move selected lines    |
| `Esc`             | Clear search highlight |

## Managing it

- `:Lazy` — plugin manager (`U` updates, `x` cleans removed plugins)
- `:Mason` — install more language servers
- `:checkhealth` — diagnose problems
- `:TSInstall <lang>` / `:TSInstallAll` — tree-sitter parsers

Installed language servers: **lua_ls, pyright, bashls, jsonls, ts_ls, eslint,
html, cssls**. Formatters: **prettier, stylua, ruff**.
Add more with `:Mason` — they auto-enable on next launch.

## JavaScript / TypeScript

Works out of the box on `.js`, `.jsx`, `.ts`, `.tsx` — no per-project setup:

- **ts_ls** gives completion, hover types, go-to-definition and rename. Type
  info comes from inference, so untyped values show as `any`; add JSDoc or a
  `jsconfig.json` for stronger results.
- **eslint** attaches only when the project has an eslint config _and_ eslint
  in `node_modules`. Without those it stays quiet, which is intended — it is
  not a global linter. `<leader>cl` applies all autofixes.
- **prettier formats on save**, honouring the project's `.prettierrc`.
  `:FormatToggle` disables it globally, `:FormatToggle!` for the current
  buffer only.
- JSX tags auto-close and rename in pairs; brackets and quotes auto-pair.

ESLint autofix is deliberately _not_ wired into save — running it alongside
prettier makes every write noticeably slower on this hardware.

## Pi-specific notes

Things that were non-obvious on this machine, in case you hit them again:

- **Neovim is not from apt.** Debian 12 ships 0.7.2, far too old for these
  plugins. v0.12.4 is installed to `/opt/nvim`, symlinked at
  `/usr/local/bin/nvim`. To upgrade, replace that directory with a newer
  `nvim-linux-arm64.tar.gz`.
- **tree-sitter CLI is pinned to v0.25.10.** Releases from v0.26 onward need
  glibc 2.39; this system has 2.36, so newer binaries won't run at all.
  `:checkhealth` reports "tree-sitter-cli v0.26.1 is required" — it's advisory,
  installing parsers works. Same trap applies to the npm `tree-sitter-cli`
  package.
- **Parsers build with `CFLAGS=-O1`** (set in `lua/plugins/treesitter.lua`).
  At the default `-O2`, GCC took 25+ minutes on a single parser and never
  finished; `-O1` does the same one in under a minute.
- **Parsers only build when missing**, so a grammar that fails doesn't get
  retried on every startup. Six parsers (c, lua, markdown, markdown_inline,
  query, vim, vimdoc) ship with Neovim and are never rebuilt.
- **Clipboard uses OSC52 over SSH.** There's no X display, so `xclip` can't
  work; yanks are sent to your local machine's clipboard via terminal escape
  codes. Pasting with `"+p` reads Neovim's own register, since most terminals
  refuse OSC52 reads. Inside a local desktop session, xclip is used instead.
- **Nerd Font**: JetBrainsMono Nerd Font v3.5.0 is installed at
  `~/.local/share/fonts/JetBrainsMonoNerdFont/`. Select family
  `JetBrainsMono Nerd Font` in the Pi's terminal preferences.
  **Over SSH this font does nothing** — glyphs are rendered by the terminal on
  the machine you're typing at, so install the same font _there_ and set it in
  that terminal. If you see blank boxes, that's the cause; alternatively set
  `vim.g.have_nerd_font = false` in `init.lua` to drop icons entirely.
