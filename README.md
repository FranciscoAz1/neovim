# Neovim setup (Raspberry Pi)

Leader key is **Space**. Press `<Space>` and pause — which-key shows what's available.

**`<leader>?` opens a cheatsheet** covering splits, terminals and tmux. tmux
shows the same page on `prefix ?`, so there is one place to look either way.

## Layout

```
~/.config/nvim/
  init.lua                   options + keymaps + plugin bootstrap
  cheatsheet.md              the <leader>? / prefix ? page — edit it, both views update
  lua/config/options.lua     editor settings, clipboard
  lua/config/keymaps.lua     global keymaps
  lua/config/windows.lua     splits, window management, terminal splits
  lua/config/cheatsheet.lua  the <leader>? popup
  lua/config/lazy.lua        plugin manager bootstrap
  lua/plugins/*.lua          one file per concern; add a file to add plugins
~/.tmux.conf                 tmux, keyed to match everything above
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
| `Ctrl-h/j/k/l`          | Move between splits — and tmux panes |

### Harpoon (the files you keep coming back to)

Telescope searches everything; harpoon is the handful of files you're actually
working in, pinned to a number so the jump is one motion and always lands in
the same place. The list is per project directory and survives restarts.

| Key                         | Action                            |
| --------------------------- | --------------------------------- |
| `<leader>ha`                | Add the current file to the list  |
| `<leader>hh` / `Ctrl-e`     | Open the list                     |
| `<leader>1` … `<leader>4`   | Jump to that slot                 |
| `<leader>hn` / `<leader>hp` | Next / previous file in the list  |

The list opens as an ordinary buffer: `dd` removes an entry, moving lines
around reorders the slots, and `q` or `<Esc>` closes it — changes are saved on
close.

From any Telescope picker, `Ctrl-v` opens the highlighted result in a vertical
split, `Ctrl-x` in a horizontal one and `Ctrl-t` in a new tab. That's usually
the fastest way to get a second file up beside the first.

### Splits & windows

| Key                         | Action                                        |
| --------------------------- | --------------------------------------------- |
| `<leader>\|` / `<leader>wv` | Split right (vertical)                        |
| `<leader>-` / `<leader>ws`  | Split below (horizontal)                      |
| `<leader>wd`                | Close this window (buffer stays open)         |
| `<leader>wo`                | Close all the other windows                   |
| `<leader>wm`                | Maximise this window — press again to restore |
| `<leader>w=`                | Even out the sizes                            |
| `<leader>wh/j/k/l`          | Move the window to that edge                  |
| `<leader>wx` / `<leader>wr` | Swap with next / rotate                       |
| `<leader>wT`                | Move the window out to its own tab            |
| `Ctrl-Arrows`               | Resize                                        |

`splitright` and `splitbelow` are on, so a new split appears where you're
already looking and the cursor moves into it. `<leader>wd` closes the _window_
and leaves the buffer loaded; `<leader>bd` is for actually closing a buffer.

`<leader>wh/j/k/l` is how you convert a stacked layout into a side-by-side one
without closing anything — it moves the current window to that edge of the
screen and rearranges the rest around it.

### Terminals

| Key          | Action                                    |
| ------------ | ----------------------------------------- |
| `<leader>tt` | Shell in a split below (toggle)           |
| `<leader>tv` | Shell in a split to the right (toggle)    |
| `<leader>tf` | Shell in a floating window (toggle)       |
| `<leader>tn` | One more shell below, not toggled         |
| `<Esc><Esc>` | Terminal → normal mode, to scroll or copy |
| `i` / `a`    | Back to typing                            |

The three toggles each keep **their own shell**. Hiding one leaves it running,
and pressing the key again brings it back with its history, working directory
and any running job intact — `<leader>tt` is a place you go back to, not a new
shell every time. Exiting the shell closes its window for good.

Entering a terminal window drops you straight into typing. Terminal splits are
`winfixheight`/`winfixwidth`, so `<leader>w=` and new splits won't squash them.

`Ctrl-h/j/k/l` works from inside a terminal without pressing `<Esc><Esc>`
first. The cost is that the shell's own `Ctrl-l` (clear screen) is unavailable
inside a Neovim terminal split — type `clear` instead. In a plain tmux pane
`Ctrl-l` still clears, because tmux only intercepts it when the pane is running
Neovim.

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
| `<leader>cc` | Toggle Claude Code terminal                    |
| `<leader>cC` | Toggle Claude Code, resuming last conversation |
| `<leader>cR` | Toggle Claude Code with conversation picker    |
| `<leader>cV` | Toggle Claude Code with verbose output         |

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

## tmux

`~/.tmux.conf` is keyed to match everything above, so splitting and closing is
the same motion whether the box you're looking at is a Neovim window or a tmux
pane. The point of adding tmux on top of Neovim's own splits is that a tmux
session **survives disconnection** — over SSH to a Pi that matters, since a
dropped link would otherwise take your editor and every running job with it.

```
tmux            start a session
tmux a          re-attach to the last one (after a dropped SSH connection)
prefix D        detach, leaving everything running
```

The prefix is **`Ctrl-Space`** — Neovim's leader with Ctrl held.

### The same keys, both sides

| Action                 | Neovim                        | tmux                                  |
| ---------------------- | ----------------------------- | ------------------------------------- |
| Move around            | `Ctrl-h/j/k/l`                | same key                              |
| Split right            | `<leader>\|` / `<leader>wv`   | `prefix \|` / `prefix v`              |
| Split below            | `<leader>-` / `<leader>ws`    | `prefix -` / `prefix s`               |
| Close this one         | `<leader>wd`                  | `prefix d`                            |
| Close all the others   | `<leader>wo`                  | `prefix o`                            |
| Maximise / zoom toggle | `<leader>wm`                  | `prefix m`                            |
| Even out the sizes     | `<leader>w=`                  | `prefix =`                            |
| Swap with next         | `<leader>wx`                  | `prefix x`                            |
| Previous / next        | `Shift-h`/`Shift-l` (buffers) | `prefix H`/`prefix L` (windows)       |
| Resize                 | `Ctrl-Arrows`                 | `Alt-Arrows`, or `prefix Ctrl-Arrows` |
| Cheatsheet             | `<leader>?`                   | `prefix ?`                            |

Plus the tmux-only ones: `prefix c` new window, `prefix 1..9` jump to window,
`prefix ,` rename, `prefix S` session picker, `prefix [` copy mode (vim keys —
`v` to select, `y` to yank), `prefix r` reload the config, `prefix /` list every
binding.

### How `Ctrl-h/j/k/l` crosses the boundary

Both halves cooperate. tmux checks whether the focused pane is running Neovim;
if it is, the keystroke is forwarded rather than acted on, and
[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) decides
whether there's a Neovim split that way — if not, it calls back into tmux to
move the pane. The upshot is that you press one set of keys and stop caring
which program owns the box. Movement stops at the edge of the screen rather
than wrapping to the far side.

### Things worth knowing

- **`prefix d` kills the pane; it does not detach.** That's the price of
  matching `<leader>wd`. Detach is `prefix D` (or `prefix Ctrl-d`), and it's
  the one you want before closing an SSH session.
- **`Ctrl-Space` is swallowed by tmux**, so nvim-cmp's manual completion
  trigger doesn't reach Neovim. `Ctrl-l` in insert mode does the same thing and
  works everywhere; `Ctrl-Space` twice also sends a real one through.
- **Neovim yanks still reach your local clipboard.** tmux normally intercepts
  the OSC52 escape sequences that make that work; `set-clipboard on` and
  `allow-passthrough on` forward them to the outer terminal instead.
- **Mouse mode is on**, matching Neovim's. Hold Shift to get your terminal's
  own text selection back when you want it.
- **`escape-time` is 10ms.** The 500ms default makes `<Esc>` in Neovim feel
  broken inside tmux.

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
- **tmux _is_ from apt** (3.3a), unlike Neovim — Debian 12's version is recent
  enough. It needs to be ≥ 3.3 for `allow-passthrough`, which is what keeps
  Neovim's OSC52 clipboard working through a tmux pane.
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
