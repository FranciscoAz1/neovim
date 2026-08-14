                    SPLITS, WINDOWS & TERMINALS

  Neovim leader is <Space>.  tmux prefix is Ctrl-Space.
  Shown by  <leader>?  in Neovim  and  prefix ?  in tmux.


─── MOVE AROUND ──────────────────────────────────────────────────────

  Ctrl-h / j / k / l      left / down / up / right
                          Crosses Neovim splits AND tmux panes: when
                          there is no split that way, you land in the
                          next tmux pane instead. Works from inside a
                          terminal split too.

  Ctrl-Arrows             resize the current Neovim split
  prefix Ctrl-Arrows      resize the current tmux pane
  Alt-Arrows              resize the current tmux pane (no prefix)


─── SPLIT ────────────────────────────────────────────────────────────

                          Neovim              tmux
  split right (vertical)  <leader>|           prefix |
                          <leader>wv          prefix v
  split below (horiz.)    <leader>-           prefix -
                          <leader>ws          prefix s

  New tmux panes open in the current pane's directory.


─── CLOSE ────────────────────────────────────────────────────────────

                          Neovim              tmux
  close this one          <leader>wd          prefix d
  close all the others    <leader>wo          prefix o
  close the buffer/win.   <leader>bd          prefix X   (whole window)

  Note: in tmux, `prefix d` kills the pane — it does NOT detach.
  Detach is `prefix D` or `prefix Ctrl-d`.


─── ARRANGE ──────────────────────────────────────────────────────────

                          Neovim              tmux
  maximise / zoom toggle  <leader>wm          prefix m
  even out the sizes      <leader>w=          prefix =
  swap with next          <leader>wx          prefix x
  rotate                  <leader>wr          prefix r  (reload cfg)
  move to far left/right  <leader>wh / wl     —
  move to top/bottom      <leader>wk / wj     —
  move out to a new tab   <leader>wT          prefix !  (pane -> window)


─── TERMINAL ─────────────────────────────────────────────────────────

  <leader>tt              shell in a split below      (toggle)
  <leader>tv              shell in a split to the right (toggle)
  <leader>tf              shell in a floating window  (toggle)
  <leader>tn              one more shell below, not toggled

  The three toggles each keep their own shell: hiding one leaves it
  running, and pressing the key again brings it back with its history,
  cwd and jobs intact. Exiting the shell closes the window for good.

  <Esc><Esc>              terminal -> normal mode (to scroll or copy)
  i  or  a                back to typing
  Ctrl-h/j/k/l            leave the terminal for another split

  Because Ctrl-l is navigation here, the shell's clear-screen is not
  available inside a Neovim terminal split — type `clear` instead. In a
  plain tmux pane Ctrl-l still clears, since tmux only intercepts it
  when the pane is running Neovim.


─── BUFFERS ──────────────────────────────────────────────────────────

  Shift-h / Shift-l       previous / next buffer
  <leader><leader>        buffer picker
  <leader>bd              close buffer


─── HARPOON (pinned files) ───────────────────────────────────────────

  <leader>ha              pin the current file
  <leader>hh  or  Ctrl-e  open the pinned list
  <leader>1 .. <leader>4  jump to that slot
  <leader>hn / <leader>hp next / previous pinned file

  The list is per project directory and survives restarts. In the list
  window: dd removes an entry, moving lines reorders the slots, q or
  <Esc> closes and saves.


─── FINDING FILES ────────────────────────────────────────────────────

  From any Telescope picker, open the highlighted result into a split:
  Ctrl-v  vertical,  Ctrl-x  horizontal,  Ctrl-t  new tab.
  That is the quickest way to get a second file up beside the first.


─── TMUX SESSIONS & WINDOWS ──────────────────────────────────────────

  tmux                    start a session
  tmux a                  re-attach to the last one
  prefix D                detach (leaves everything running)
  prefix c                new window
  prefix H / L            previous / next window   (like Shift-h/l)
  prefix 1..9             jump to window by number
  prefix ,                rename window
  prefix S                session picker
  prefix r                reload ~/.tmux.conf
  prefix [                copy mode — vim keys, v to select, y to yank
  prefix ?                this cheatsheet
  prefix /                every tmux binding

  Inside tmux, Ctrl-Space is the prefix, so Neovim never sees it. Press
  it twice to send a real Ctrl-Space through (that's cmp's manual
  completion trigger).
