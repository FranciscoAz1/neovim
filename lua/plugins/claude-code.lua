return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose" },
  keys = {
    "<leader>cc",
    "<leader>cC",
    "<leader>cR",
    "<leader>cV",
  },
  opts = {
    keymaps = {
      toggle = {
        normal = "<leader>cc", -- keep the "c" (code) namespace consistent with lsp.lua/format.lua
        terminal = "<C-,>",
        variants = {
          continue = "<leader>cC",
          resume = "<leader>cR",
          verbose = "<leader>cV",
        },
      },
      -- Terminal-mode <C-h/j/k/l> would otherwise fight vim-tmux-navigator's
      -- terminal-mode mappings (lua/plugins/tmux.lua), which are load-bearing
      -- for split/pane navigation over SSH+tmux.
      window_navigation = false,
    },
  },
  config = function(_, opts)
    require("claude-code").setup(opts)
  end,
}
