-- Ctrl-h/j/k/l moves between Neovim splits; when there is no split that way and
-- Neovim is running inside tmux, it steps into the neighbouring tmux pane
-- instead. One set of keys for both, so you stop having to think about which
-- program owns the box you're looking at.
--
-- The other half of this lives in ~/.tmux.conf, which does the mirror image:
-- it checks whether the focused pane is running Neovim and, if so, forwards the
-- keystroke here rather than acting on it.
return {
  "christoomey/vim-tmux-navigator",
  init = function()
    -- We define the mappings ourselves below so they also cover terminal mode
    vim.g.tmux_navigator_no_mappings = 1
    -- A zoomed tmux pane stays zoomed; navigation is confined to it
    vim.g.tmux_navigator_disable_when_zoomed = 1
    -- Stop at the edge of the screen. Without this, Ctrl-h at the leftmost
    -- split teleports you to the far right, which is disorienting.
    vim.g.tmux_navigator_no_wrap = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
  },
  keys = {
    -- mode "t" means these work from inside a terminal split too, without
    -- having to press <Esc><Esc> first
    { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", mode = { "n", "t" }, desc = "Go left (split/pane)" },
    { "<C-j>", "<cmd>TmuxNavigateDown<CR>", mode = { "n", "t" }, desc = "Go down (split/pane)" },
    { "<C-k>", "<cmd>TmuxNavigateUp<CR>", mode = { "n", "t" }, desc = "Go up (split/pane)" },
    { "<C-l>", "<cmd>TmuxNavigateRight<CR>", mode = { "n", "t" }, desc = "Go right (split/pane)" },
  },
}
