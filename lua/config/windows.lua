-- Splits, window management and terminal splits.
--
-- Two families of keys:
--   <leader>w…  windows (split, close, resize, move)
--   <leader>t…  terminals (a shell in a split or a float)
--
-- Both are mirrored in ~/.tmux.conf under the tmux prefix, so the same motions
-- work whether the thing you want to split is a Neovim window or a tmux pane.
-- Moving between them is Ctrl-h/j/k/l either way — see lua/plugins/tmux.lua.

local map = vim.keymap.set

--------------------------------------------------------------------------
-- Splits
--------------------------------------------------------------------------
-- splitright / splitbelow are on (options.lua), so a new split appears where
-- you are already looking rather than shoving the current buffer aside.

map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split right (vertical)" })
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "Split below (horizontal)" })
-- Shorthand: the key looks like the split it makes
map("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Split right (vertical)" })
map("n", "<leader>-", "<cmd>split<CR>", { desc = "Split below (horizontal)" })

--------------------------------------------------------------------------
-- Closing
--------------------------------------------------------------------------
-- <C-w>c closes the window but keeps the buffer loaded, which is almost always
-- what you want: <leader>bd is for actually getting rid of a buffer.

map("n", "<leader>wd", "<C-w>c", { desc = "Close window" })
map("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })

--------------------------------------------------------------------------
-- Sizing
--------------------------------------------------------------------------
map("n", "<leader>w=", "<C-w>=", { desc = "Equalise window sizes" })

-- Zoom the current split to fill the screen, press again to put everything
-- back. winrestcmd() returns the :resize commands that rebuild the current
-- layout, so restoring is exact rather than just an equalise.
local saved_layout = nil
map("n", "<leader>wm", function()
  if saved_layout then
    pcall(vim.cmd, saved_layout)
    saved_layout = nil
    return
  end
  if vim.fn.winnr("$") == 1 then
    return vim.notify("Only one window", vim.log.levels.INFO)
  end
  saved_layout = vim.fn.winrestcmd()
  vim.cmd("wincmd _") -- max height
  vim.cmd("wincmd |") -- max width
end, { desc = "Maximise window (toggle)" })

--------------------------------------------------------------------------
-- Rearranging
--------------------------------------------------------------------------
-- <C-w>H and friends move the *window* to an edge, which is how you turn a
-- stacked layout into a side-by-side one without closing anything.
map("n", "<leader>wh", "<C-w>H", { desc = "Move window far left" })
map("n", "<leader>wj", "<C-w>J", { desc = "Move window to bottom" })
map("n", "<leader>wk", "<C-w>K", { desc = "Move window to top" })
map("n", "<leader>wl", "<C-w>L", { desc = "Move window far right" })
map("n", "<leader>wx", "<C-w>x", { desc = "Swap with next window" })
map("n", "<leader>wr", "<C-w>r", { desc = "Rotate windows" })
map("n", "<leader>wT", "<C-w>T", { desc = "Move window to new tab" })

--------------------------------------------------------------------------
-- Terminal splits
--------------------------------------------------------------------------
-- One terminal per position, remembered across toggles: pressing <leader>tt
-- again gives you the same shell back — history, cwd and running jobs intact —
-- instead of spawning a new one every time.

local terms = {} -- "below" | "right" | "float"  ->  { buf, win }

local function open_split(pos, buf)
  if pos == "below" then
    vim.cmd("botright " .. math.max(10, math.floor(vim.o.lines * 0.3)) .. "split")
  else
    vim.cmd("botright " .. math.max(40, math.floor(vim.o.columns * 0.4)) .. "vsplit")
  end
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  -- Don't let <C-w>= or new splits squash the terminal
  vim.wo[win][0].winfixheight = true
  vim.wo[win][0].winfixwidth = true
  vim.wo[win][0].number = false
  vim.wo[win][0].relativenumber = false
  vim.wo[win][0].signcolumn = "no"
  return win
end

local function open_float(buf)
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.8)
  return vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " terminal ",
    title_pos = "center",
  })
end

local function show(pos, buf)
  if pos == "float" then
    return open_float(buf)
  end
  return open_split(pos, buf)
end

local function toggle(pos)
  local t = terms[pos]

  -- Visible: hide it (the shell keeps running in the background)
  if t and t.win and vim.api.nvim_win_is_valid(t.win) then
    pcall(vim.api.nvim_win_close, t.win, false)
    t.win = nil
    return
  end

  -- Hidden but alive: put it back on screen
  if t and t.buf and vim.api.nvim_buf_is_valid(t.buf) then
    t.win = show(pos, t.buf)
    vim.cmd("startinsert")
    return
  end

  -- Nothing yet: new buffer, new shell
  t = { buf = vim.api.nvim_create_buf(false, false) }
  terms[pos] = t
  t.win = show(pos, t.buf)
  vim.fn.jobstart(vim.o.shell, {
    term = true,
    on_exit = function()
      vim.schedule(function()
        terms[pos] = nil
        if t.win and vim.api.nvim_win_is_valid(t.win) then
          pcall(vim.api.nvim_win_close, t.win, true)
        end
        if vim.api.nvim_buf_is_valid(t.buf) then
          pcall(vim.api.nvim_buf_delete, t.buf, { force = true })
        end
      end)
    end,
  })
  vim.cmd("startinsert")
end

map("n", "<leader>tt", function() toggle("below") end, { desc = "Terminal below (toggle)" })
map("n", "<leader>tv", function() toggle("right") end, { desc = "Terminal right (toggle)" })
map("n", "<leader>tf", function() toggle("float") end, { desc = "Terminal floating (toggle)" })

-- An extra, throwaway terminal for when you want two shells side by side.
-- Not toggled or reused — close it with <leader>wd or by exiting the shell.
map("n", "<leader>tn", function()
  vim.cmd("botright " .. math.max(10, math.floor(vim.o.lines * 0.3)) .. "split")
  vim.cmd("enew")
  vim.fn.jobstart(vim.o.shell, { term = true })
  vim.cmd("startinsert")
end, { desc = "New terminal below" })

-- Terminal buffers shouldn't carry editor chrome, and should start ready to type
local grp = vim.api.nvim_create_augroup("terminal-ui", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  group = grp,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
})

-- Coming back to a terminal window drops you straight into typing, the way a
-- terminal is expected to behave. <Esc><Esc> still gets you to normal mode for
-- scrolling and copying, and staying in that window keeps you there.
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = grp,
  pattern = "term://*",
  callback = function()
    if vim.bo.buftype == "terminal" and vim.b.terminal_job_id then
      vim.cmd("startinsert")
    end
  end,
})
