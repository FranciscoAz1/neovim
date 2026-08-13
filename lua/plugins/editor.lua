return {
  -- gcc / gc{motion} to comment, like Ctrl-/ in VS Code
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    config = function(_, opts)
      require("Comment").setup(opts)
      vim.keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
      vim.keymap.set("v", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })
      -- Some terminals send <C-/> literally instead of <C-_>
      vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
      vim.keymap.set("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })
    end,
  },

  -- Auto-close brackets and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      local ok, cmp = pcall(require, "cmp")
      if ok then
        cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end
    end,
  },

  -- Auto-close/rename HTML & JSX tags
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte", "vue", "xml" },
    opts = {},
  },

  -- Project-wide search & replace panel (VS Code's Ctrl-Shift-H)
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>fR", "<cmd>GrugFar<CR>", desc = "Search & replace in project" },
    },
    opts = {},
  },

  -- Trouble: a diagnostics/quickfix panel, like VS Code's Problems tab
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Workspace diagnostics" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<CR>", desc = "Symbol outline" },
    },
    opts = {},
  },
}
