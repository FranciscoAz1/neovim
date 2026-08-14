-- The helper: <leader>? pops up ~/.config/nvim/cheatsheet.md in a float.
--
-- It's a plain text file rather than a generated list so that tmux can show the
-- exact same page (prefix ?, via display-popup) — one document covering both
-- halves of the setup. Edit cheatsheet.md and both views update.

local M = {}

local path = vim.fn.stdpath("config") .. "/cheatsheet.md"

function M.open()
  if vim.fn.filereadable(path) == 0 then
    return vim.notify("No cheatsheet at " .. path, vim.log.levels.WARN)
  end

  local lines = vim.fn.readfile(path)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(74, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 6)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " cheatsheet ",
    title_pos = "center",
  })
  vim.wo[win].wrap = false

  -- Enough highlighting to skim by; window-local, so it dies with the float
  vim.fn.matchadd("Title", [[^─\{3}.*]])
  vim.fn.matchadd("Identifier", [[<[A-Za-z<>-]\+>]])
  vim.fn.matchadd("Identifier", [[\<\%(Ctrl\|Alt\|Shift\)-[A-Za-z]\+]])
  vim.fn.matchadd("Identifier", [[\<prefix\>]])

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = buf, nowait = true, desc = "Close cheatsheet" })
  end
end

vim.api.nvim_create_user_command("Cheatsheet", M.open, { desc = "Splits/terminal/tmux cheatsheet" })
vim.keymap.set("n", "<leader>?", M.open, { desc = "Cheatsheet (splits, terminals, tmux)" })

return M
