-- Formatting. Language servers format poorly (or not at all) for web code, so
-- route those filetypes through prettier and fall back to the LSP elsewhere.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      lua = { "stylua" },
      python = { "ruff_format" },
    },
    -- Prettier respects the project's own .prettierrc when there is one
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      -- Prettier is node-based and not instant on a Pi; the timeout keeps a
      -- slow format from blocking the write
      return { timeout_ms = 3000, lsp_format = "fallback" }
    end,
  },
  config = function(_, opts)
    require("conform").setup(opts)

    vim.api.nvim_create_user_command("FormatToggle", function(args)
      if args.bang then
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        vim.notify("Buffer autoformat: " .. (vim.b.disable_autoformat and "off" or "on"))
      else
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify("Autoformat: " .. (vim.g.disable_autoformat and "off" or "on"))
      end
    end, { bang = true, desc = "Toggle format-on-save (! for current buffer)" })
  end,
}
