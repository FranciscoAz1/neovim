local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false -- lualine already shows it
opt.scrolloff = 999 -- keep cursor vertically centered via native smooth scroll (see keymaps.lua)
opt.sidescrolloff = 8
opt.wrap = false
opt.splitright = true
opt.splitbelow = true
opt.laststatus = 3 -- one global statusline

-- Indentation
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Files / undo
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.confirm = true

-- Performance (matters on a Pi)
opt.updatetime = 250
opt.timeoutlen = 400
opt.lazyredraw = false -- keep false: breaks some plugin redraws
opt.synmaxcol = 300

-- Behaviour
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- shares with the system clipboard

-- Over SSH there is no X display, so xclip can't reach a clipboard. Fall back
-- to OSC52 escape sequences, which make the *terminal* do the copying — that
-- lands text in the clipboard of whatever machine you're sitting at.
if vim.env.SSH_TTY and not vim.env.DISPLAY then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    -- Most terminals refuse OSC52 reads, so paste from Neovim's own registers
    paste = { ["+"] = function() return vim.split(vim.fn.getreg('"'), "\n") end,
              ["*"] = function() return vim.split(vim.fn.getreg('"'), "\n") end },
  }
end
opt.completeopt = "menu,menuone,noselect"
opt.inccommand = "split" -- live preview of :%s///
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
