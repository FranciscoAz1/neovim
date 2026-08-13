-- Git integration. gitsigns gives the VS Code gutter + inline blame; heavier
-- operations (staging, rebasing, log browsing) go to lazygit via <leader>gg.
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "契" },
        topdelete = { text = "契" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame = false, -- toggle with <leader>gB
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, keys, fn, desc)
          vim.keymap.set(mode, keys, fn, { buffer = bufnr, desc = "Git: " .. desc })
        end

        map("n", "]h", function()
          gs.nav_hunk("next")
        end, "Next hunk")
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, "Previous hunk")

        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>gS", gs.stage_hunk, "Stage hunk")
        map("v", "<leader>gS", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selected hunk")
        map("n", "<leader>gd", gs.diffthis, "Diff this file")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
      end,
    },
  },

  -- :Git commands for the things lazygit doesn't cover (blame, :Gedit, etc.)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Gblame" },
  },
}
