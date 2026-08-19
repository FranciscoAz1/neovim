-- Zen mode: a fixed-width, centered writing column with everything else
-- (statusline, gutter, tabline) hidden. Twilight dims prose/code outside the
-- current paragraph/scope so the middle of the screen is what draws the eye.
return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>zz", "<cmd>ZenMode<CR>", desc = "Toggle zen mode" },
    },
    opts = {
      window = {
        width = 90, -- fixed columns; neovim centers the window in the screen
        options = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
        },
      },
      plugins = {
        twilight = { enabled = true }, -- dim everything outside the current scope
        gitsigns = { enabled = false }, -- keep the sign column decision above authoritative
        tmux = { enabled = false }, -- don't touch tmux status bar on toggle
      },
    },
  },

  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    opts = {
      dimming = { alpha = 0.25 },
      context = 10, -- lines of context kept undimmed around the cursor
    },
  },
}
