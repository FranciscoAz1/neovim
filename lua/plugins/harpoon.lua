-- Harpoon: a tiny, hand-picked list of the files you're actually working on.
-- Telescope searches everything; harpoon is the four or five files you keep
-- bouncing between, pinned to <leader>1..4 so the jump is one motion and
-- always lands in the same place. The list is per project directory and
-- persists across restarts (saved under stdpath("data")/harpoon).
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<leader>ha",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Add file to harpoon",
    },
    {
      "<leader>hh",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Harpoon menu",
    },
    {
      -- Same menu on a chord, for when <leader> is too many keystrokes
      "<C-e>",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Harpoon menu",
    },
    {
      "<leader>hp",
      function()
        require("harpoon"):list():prev()
      end,
      desc = "Previous harpoon file",
    },
    {
      "<leader>hn",
      function()
        require("harpoon"):list():next()
      end,
      desc = "Next harpoon file",
    },
    -- Jump straight to a slot; the number matches the line in the menu
    {
      "<leader>1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon file 1",
    },
    {
      "<leader>2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon file 2",
    },
    {
      "<leader>3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon file 3",
    },
    {
      "<leader>4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon file 4",
    },
  },
  -- The quick menu is a plain buffer harpoon sets up itself: dd removes an
  -- entry, reordering lines reorders the slots, q/<Esc> close, <CR> opens.
  opts = {
    settings = {
      save_on_toggle = true, -- edits in the menu apply when you close it
      sync_on_ui_close = true, -- write the list to disk there and then
    },
  },
  config = function(_, opts)
    require("harpoon"):setup(opts)
  end,
}
