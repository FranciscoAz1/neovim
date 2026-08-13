-- Tree-sitter: syntax highlighting, indentation and structural text objects.
-- Uses the `main` branch, which is the supported one on Neovim 0.11+.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    -- Parser sources are single generated C files of 3 MB+; GCC at the default
    -- -O2 can spend 25+ minutes on one of those on Pi-class hardware (the
    -- gitcommit grammar never finished). -O1 builds the same parser in under a
    -- minute with no meaningful runtime difference.
    if not vim.env.CFLAGS then
      vim.env.CFLAGS = "-O1"
    end

    require("nvim-treesitter").setup({})

    local parsers = {
      "bash",
      "c",
      "cpp",
      "css",
      "diff",
      "git_config",
      "gitcommit",
      "gitignore",
      "html",
      "javascript",
      "json",
      "lua",
      "luadoc",
      "make",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    }

    -- Only compile parsers that are genuinely missing. The runtime-file check
    -- also catches the ones Neovim bundles (c, lua, markdown, query, vim,
    -- vimdoc), so we never rebuild those. Without this guard a parser that
    -- fails to build would be retried on every single startup.
    local missing = {}
    for _, lang in ipairs(parsers) do
      if #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) == 0 then
        table.insert(missing, lang)
      end
    end
    if #missing > 0 then
      require("nvim-treesitter").install(missing)
    end

    -- Rebuild everything on demand after an update
    vim.api.nvim_create_user_command("TSInstallAll", function()
      require("nvim-treesitter").install(parsers, { force = true })
    end, { desc = "Reinstall all configured tree-sitter parsers" })

    -- On the main branch, highlighting is opt-in per buffer.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
      callback = function(ev)
        if vim.bo[ev.buf].buftype ~= "" then
          return
        end
        -- Skip very large files: parsing them on a Pi is not worth the stall
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
        if ok and stats and stats.size > 512 * 1024 then
          return
        end
        if pcall(vim.treesitter.start, ev.buf) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
