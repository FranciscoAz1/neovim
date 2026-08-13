-- LSP: go-to-definition, hover docs, rename, diagnostics, formatting.
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        -- All of these have working aarch64 installs. Add more with :Mason
        ensure_installed = {
          "lua_ls",
          "pyright",
          "bashls",
          "jsonls",
          -- Web / JavaScript
          "ts_ls", -- JavaScript + TypeScript
          "eslint", -- linting, only active when the project has an eslint config
          "html",
          "cssls",
        },
        automatic_enable = true,
      })

      -- Lua: teach it about the Neovim runtime so editing this config is pleasant
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      -- Buffer-local keymaps, applied only where a server is actually attached
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local function map(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", "<cmd>Telescope lsp_definitions<CR>", "Goto definition")
          map("gr", "<cmd>Telescope lsp_references<CR>", "Goto references")
          map("gI", "<cmd>Telescope lsp_implementations<CR>", "Goto implementation")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cs", "<cmd>Telescope lsp_document_symbols<CR>", "Document symbols")
          -- <leader>cf is owned by conform.nvim (see plugins/format.lua); it
          -- falls back to vim.lsp.buf.format when no formatter is configured.

          -- Highlight other references to the symbol under the cursor
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- eslint --fix for the whole buffer. Deliberately manual rather than
          -- on-save: chaining it with prettier makes every write noticeably
          -- slower on this hardware.
          if client and client.name == "eslint" then
            map("<leader>cl", "<cmd>LspEslintFixAll<CR>", "ESLint fix all")
          end
          if client and client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = true,
        virtual_text = { spacing = 2, source = "if_many" },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or true,
      })
    end,
  },
}
