-- Start screen: snacks.nvim's dashboard, shown when nvim opens with no file.
-- Jump back to a recent place, open the config, update plugins, read logs.
-- Picking a place `cd`s into it, so terminals (<leader>t…) open there too —
-- see the DirChanged handling in lua/config/windows.lua.
--
-- Reopen it any time with <leader>d.

-- "Recent places" = directories nvim was started in or `:cd`'d to, newest
-- first. Snacks' own project list only knows git roots of recent files, which
-- misses plain folders, so we keep our own small history file.
local history_file = vim.fs.joinpath(vim.fn.stdpath("state"), "recent_dirs.json")
local max_dirs = 20

local function read_dirs()
  local f = io.open(history_file, "r")
  if not f then
    return {}
  end
  local ok, dirs = pcall(vim.json.decode, f:read("*a"))
  f:close()
  return ok and type(dirs) == "table" and dirs or {}
end

local function remember_dir(dir)
  dir = vim.fs.normalize(dir)
  -- Home is where a bare `nvim` starts; listing it would just be noise
  if dir == vim.fs.normalize(vim.env.HOME or "~") then
    return
  end
  local dirs = { dir }
  for _, d in ipairs(read_dirs()) do
    if d ~= dir and #dirs < max_dirs then
      table.insert(dirs, d)
    end
  end
  vim.fn.mkdir(vim.fn.fnamemodify(history_file, ":h"), "p")
  local f = io.open(history_file, "w")
  if f then
    f:write(vim.json.encode(dirs))
    f:close()
  end
end

-- Recorded dirs first, then git roots of recent files so the list isn't empty
-- before any history has built up.
local function recent_places()
  local seen, out = {}, {}
  local function add(dir)
    if dir and not seen[dir] and vim.fn.isdirectory(dir) == 1 then
      seen[dir] = true
      table.insert(out, dir)
    end
  end
  for _, d in ipairs(read_dirs()) do
    add(d)
  end
  for _, file in ipairs(vim.v.oldfiles) do
    if #out >= 8 then
      break
    end
    add(Snacks.git.get_root(file))
  end
  return out
end

-- Every *log file in nvim's log dir (nvim, lsp, mason, conform...), newest
-- first. Globbing only the top level matters on Windows, where this dir is
-- also the data dir holding every plugin.
local function pick_log()
  local dir = vim.fn.stdpath("log")
  local files = vim.fn.glob(vim.fs.joinpath(dir, "*log"), false, true)
  table.sort(files, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)
  if #files == 0 then
    return vim.notify("No log files in " .. dir, vim.log.levels.INFO)
  end
  local conf = require("telescope.config").values
  require("telescope.pickers")
    .new({}, {
      prompt_title = "Logs",
      finder = require("telescope.finders").new_table({
        results = files,
        entry_maker = require("telescope.make_entry").gen_from_file({ cwd = dir }),
      }),
      sorter = conf.file_sorter({}),
      previewer = conf.file_previewer({}),
    })
    :find()
end

-- :messages in a scratch buffer, so startup errors can be scrolled and searched
local function show_messages()
  local out = vim.api.nvim_exec2("messages", { output = true }).output
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.api.nvim_buf_set_name(0, "[messages]")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(out ~= "" and out or "(no messages)", "\n"))
  vim.bo.modifiable = false
end

local function open_config()
  vim.fn.chdir(vim.fn.stdpath("config"))
  require("telescope.builtin").find_files()
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    local grp = vim.api.nvim_create_augroup("recent-places", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
      group = grp,
      callback = function()
        remember_dir(vim.fn.getcwd())
      end,
    })
    vim.api.nvim_create_autocmd("DirChanged", {
      group = grp,
      pattern = "global",
      callback = function()
        remember_dir(vim.v.event.cwd)
      end,
    })
  end,
  keys = {
    {
      "<leader>d",
      function()
        Snacks.dashboard()
      end,
      desc = "Dashboard (home)",
    },
  },
  opts = {
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find file", action = ":Telescope find_files" },
          { icon = " ", key = "g", desc = "Grep", action = ":Telescope live_grep" },
          { icon = " ", key = "r", desc = "Recent files", action = ":Telescope oldfiles" },
          { icon = " ", key = "n", desc = "New file", action = ":ene | startinsert" },
          { icon = " ", key = "c", desc = "Config", action = open_config },
          { icon = "󰒲 ", key = "u", desc = "Update plugins", action = ":Lazy sync" },
          { icon = " ", key = "M", desc = "Mason", action = ":Mason" },
          { icon = " ", key = "h", desc = "Health check", action = ":checkhealth" },
          { icon = " ", key = "e", desc = "Errors / messages", action = show_messages },
          { icon = " ", key = "l", desc = "Log files", action = pick_log },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", padding = 1 },
        -- Number keys 1-9 pick a place: cd there, then open the file finder
        { icon = " ", title = "Recent places", section = "projects", dirs = recent_places, limit = 8, indent = 2, padding = 1 },
        { icon = " ", title = "Recent files", section = "recent_files", limit = 5, indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
  },
}
