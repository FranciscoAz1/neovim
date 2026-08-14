-- Neovim config: a lightweight VS Code-like setup
-- Entry point. Options + keymaps live here, plugins in lua/plugins/.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Set to false if your terminal font is NOT a Nerd Font (icons become blank boxes)
vim.g.have_nerd_font = true

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.windows")
require("config.cheatsheet")
