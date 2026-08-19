# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim configuration (not an application with a build/test suite). It targets a
Raspberry Pi over SSH+tmux specifically — several files exist to work around that hardware, not
just general Neovim setup. There is no test runner, linter, or CI; "correctness" is verified by
launching Neovim and exercising the keymap/plugin in question.

## Commands

There is no build system. Everything runs inside Neovim itself:

- `:Lazy` — plugin manager UI (`U` update all, `x` remove plugins no longer in the spec)
- `:Lazy sync` (or headless: `nvim --headless "+Lazy! sync" +qa`) — install/update/clean in one shot
- `:Mason` — install/remove language servers and formatters
- `:checkhealth` — diagnose plugin/LSP/treesitter problems
- `:TSInstall <lang>` — install one tree-sitter parser; `:TSInstallAll` — force-reinstall all configured parsers (defined in `lua/plugins/treesitter.lua`)
- `:FormatToggle` / `:FormatToggle!` — disable format-on-save globally / for the current buffer (`lua/plugins/format.lua`)
- `:Cheatsheet` (or `<leader>?`) — open `cheatsheet.md` in a floating window

`lazy-lock.json` pins exact plugin commits; commit it whenever `:Lazy` changes versions so the Pi
stays reproducible.

## Architecture

**Load order** (`init.lua`): leader keys → `config.options` → `config.lazy` (bootstraps
lazy.nvim, which requires every file under `lua/plugins/`) → `config.keymaps` → `config.windows` →
`config.cheatsheet`. Adding a new plugin file to `lua/plugins/` is enough to have it picked up —
`lua/config/lazy.lua` imports the whole directory via `spec = { { import = "plugins" } } }`.

**File split**: `lua/config/*.lua` holds hand-written, non-plugin config (options, global keymaps,
window/terminal management, the cheatsheet popup). `lua/plugins/*.lua` is one file per concern —
each file returns a lazy.nvim plugin spec (or a list of specs). When adding functionality, prefer
putting it in the plugin file it belongs to rather than growing `config/keymaps.lua`.

**Keymap namespacing under `<leader>`**: `f` find, `g` git, `c` code, `b` buffer, `x`
diagnostics, `w` window, `t` terminal, `h` harpoon (declared as which-key groups in
`lua/plugins/ui.lua`). Follow this scheme for new bindings so they show up correctly in which-key
and don't collide.

**`cheatsheet.md` is the single source of truth for keybindings**, rendered both by Neovim
(`<leader>?`, via `lua/config/cheatsheet.lua`) and by tmux (`prefix ?`, via `~/.tmux.conf`'s
`display-popup`). It intentionally only covers splits/windows/terminals/tmux, not every keymap in
the config (see `README.md` for the full table). Editing this file updates both views — don't
create a second cheatsheet.

**tmux integration is load-bearing, not cosmetic.** `~/.tmux.conf` is keyed to mirror the Neovim
window keymaps (`<leader>w*` ↔ `prefix *`) and `Ctrl-h/j/k/l` crosses between Neovim splits and
tmux panes via `lua/plugins/tmux.lua` (vim-tmux-navigator) cooperating with tmux's own pane-aware
bindings. Changes to window/split keymaps in `lua/config/windows.lua` should stay in sync with
`~/.tmux.conf` (outside this repo) and with `cheatsheet.md`'s "same keys, both sides" table.
`Ctrl-Space` is swallowed by tmux as its prefix, so cmp's manual completion trigger is bound to
`Ctrl-l` instead of the conventional `Ctrl-Space` (`lua/plugins/completion.lua`).

**Terminals are position-keyed singletons**, not one-shot spawns: `lua/config/windows.lua` keeps a
`terms` table keyed by `"below" | "right" | "float"`, so `<leader>tt` repeatedly toggles the same
shell (history/cwd/job intact) rather than creating a new one. `<leader>tn` is the deliberate
exception — an unmanaged, throwaway extra terminal.

**LSP config lives entirely in `lua/plugins/lsp.lua`**: mason-lspconfig installs servers and
`automatic_enable`s them; buffer-local keymaps (`gd`, `gr`, `K`, `<leader>cr`, etc.) are attached
via a single `LspAttach` autocmd rather than per-server config. Formatting is handled separately by
conform.nvim (`lua/plugins/format.lua`), which runs prettier/stylua/ruff and falls back to
`vim.lsp.buf.format` — don't add formatting logic to the LSP file. eslint autofix
(`<leader>cl`) is deliberately kept out of format-on-save because chaining it with prettier is
noticeably slow on Pi hardware.

## Pi-specific constraints (read before touching these areas)

- **Neovim is not the apt package** — it's v0.12.4 installed manually to `/opt/nvim`, symlinked at
  `/usr/local/bin/nvim`. Don't assume `apt upgrade` affects it.
- **tree-sitter CLI is pinned to v0.25.10**; v0.26+ needs a newer glibc than this system has.
  `:checkhealth` will warn about this — it's advisory, not a real problem.
- **Parser builds force `CFLAGS=-O1`** (`lua/plugins/treesitter.lua`) because `-O2` takes 25+
  minutes per parser on this hardware. Keep this when touching that file.
- **Parsers only install when missing** (checked via `nvim_get_runtime_file`) so a failing grammar
  doesn't retry every startup. Six parsers ship built into Neovim and are excluded automatically.
- **No trash-cli** — oil.nvim deletes are permanent (`delete_to_trash = false` in
  `lua/plugins/explorer.lua`); don't change this without adding a safety net.
- **Clipboard over SSH uses OSC52**, not xclip/X11 (`lua/config/options.lua`), and tmux needs
  `allow-passthrough on` (≥ tmux 3.3) for it to reach the local machine.

## Notes on repo state

`lua/plugins/zenmode.lua` adds `folke/zen-mode.nvim` with default opts and no keymap/command wired
up yet — it won't do anything until a trigger is added.
