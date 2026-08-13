return {
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "night", styles = { comments = { italic = false } } },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Icons (needs a Nerd Font in your terminal)
  {
    "nvim-tree/nvim-web-devicons",
    enabled = vim.g.have_nerd_font,
    lazy = true,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        icons_enabled = vim.g.have_nerd_font,
        component_separators = "|",
        section_separators = "",
        globalstatus = true,
      },
      sections = {
        lualine_c = { { "filename", path = 1 } },
      },
    },
  },

  -- Buffer tabs across the top, like VS Code
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        show_buffer_icons = vim.g.have_nerd_font,
        separator_style = "slant",
        -- No sidebar offset needed: oil opens in a normal window or a float
      },
    },
  },

  -- Keybinding discovery: press <leader> and wait
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
        { "<leader>b", group = "buffer" },
        { "<leader>x", group = "diagnostics" },
      },
    },
  },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = false }, -- scope needs treesitter queries every redraw; skip on a Pi
    },
  },
}
