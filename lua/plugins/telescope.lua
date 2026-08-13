-- Fuzzy finder: the Ctrl-P / Ctrl-Shift-F half of the VS Code experience.
return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      -- Native C sorter; much faster than the Lua fallback on a Pi
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },
  keys = {
    { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep in project" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
    { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
    { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
    { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Git branches" },
    { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Git status" },
    { "<leader><leader>", "<cmd>Telescope buffers<CR>", desc = "Switch buffer" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        path_display = { "truncate" },
        file_ignore_patterns = { "%.git/", "node_modules/", "__pycache__/", "%.venv/" },
        mappings = {
          i = {
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
            ["<Esc>"] = require("telescope.actions").close,
          },
        },
      },
      pickers = {
        find_files = { hidden = true },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
