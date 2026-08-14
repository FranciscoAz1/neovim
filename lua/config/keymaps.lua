local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save / quit (VS Code muscle memory)
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR><Esc>", { desc = "Save file" })

-- Window navigation is Ctrl-h/j/k/l, defined in lua/plugins/tmux.lua so that
-- the same keys also cross into tmux panes. Splits, closing and terminals live
-- in lua/config/windows.lua.

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Grow window" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shrink window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Narrow window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Widen window" })

-- Buffers (VS Code-ish tab cycling)
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Move selected lines (Alt+Up/Down like VS Code)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centred when scrolling / searching
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Indent without losing selection
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Terminal: escape to normal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- lazygit in a full-screen terminal tab (no plugin needed)
map("n", "<leader>gg", function()
  vim.cmd("tabnew")
  vim.fn.jobstart({ "lazygit" }, {
    term = true,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(0) then
          vim.cmd("bdelete!")
        end
      end)
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Lazygit" })
