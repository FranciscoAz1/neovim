-- File explorer: oil.nvim. Directories open as normal, editable buffers —
-- rename a file by editing its line, delete with `dd`, create with `o`, then
-- `:w` to apply. Netrw is disabled in config/lazy.lua so oil owns directories.
return {
  "stevearc/oil.nvim",
  dependencies = vim.g.have_nerd_font and { "nvim-tree/nvim-web-devicons" } or {},
  -- Not lazy: oil must already be loaded to handle `nvim .` or `nvim some/dir`
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
    {
      "<C-b>",
      function()
        require("oil").toggle_float()
      end,
      desc = "Toggle file explorer (float)",
    },
    {
      "<leader>o",
      function()
        require("oil").open(vim.fn.getcwd())
      end,
      desc = "Open explorer at project root",
    },
  },
  opts = {
    default_file_explorer = true,
    columns = vim.g.have_nerd_font and { "icon" } or {},
    delete_to_trash = false, -- no trash-cli on this box; deletes are permanent
    skip_confirm_for_simple_edits = false,
    view_options = {
      show_hidden = true,
      -- .git itself is noise; its contents are never edited by hand
      is_always_hidden = function(name)
        return name == ".git" or name == ".."
      end,
    },
    float = {
      padding = 4,
      max_width = 100,
      max_height = 30,
    },
    keymaps = {
      ["q"] = { "actions.close", mode = "n" },
      ["<C-h>"] = false, -- keep window-left navigation
      ["<C-l>"] = false, -- keep window-right navigation
      ["<C-r>"] = "actions.refresh",
      ["gd"] = {
        desc = "Toggle detail view (permissions, size, mtime)",
        callback = function()
          vim.b.oil_detail = not vim.b.oil_detail
          local detailed = { "icon", "permissions", "size", "mtime" }
          require("oil").set_columns(vim.b.oil_detail and detailed or { "icon" })
        end,
      },
    },
  },
}
