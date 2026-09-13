-- Shows the pending keybinds for whatever prefix you have typed.
return {
  "folke/which-key.nvim",
  -- VeryLazy rather than VimEnter: the popup is delayed 300ms behind a
  -- keypress, so it cannot be needed before the first screen draw.
  event = "VeryLazy",
  opts = {
    -- Show the popup only after a deliberate pause, so it helps when you
    -- hesitate but stays out of the way during fluent editing.
    -- (independent of vim.o.timeoutlen)
    delay = 300,
    icons = {
      -- set icon mappings to true if you have a Nerd Font
      mappings = vim.g.have_nerd_font,
      -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
      -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
      keys = vim.g.have_nerd_font and {} or {
        Up = "<Up> ",
        Down = "<Down> ",
        Left = "<Left> ",
        Right = "<Right> ",
        C = "<C-…> ",
        M = "<M-…> ",
        D = "<D-…> ",
        S = "<S-…> ",
        CR = "<CR> ",
        Esc = "<Esc> ",
        ScrollWheelDown = "<ScrollWheelDown> ",
        ScrollWheelUp = "<ScrollWheelUp> ",
        NL = "<NL> ",
        BS = "<BS> ",
        Space = "<Space> ",
        Tab = "<Tab> ",
        F1 = "<F1>",
        F2 = "<F2>",
        F3 = "<F3>",
        F4 = "<F4>",
        F5 = "<F5>",
        F6 = "<F6>",
        F7 = "<F7>",
        F8 = "<F8>",
        F9 = "<F9>",
        F10 = "<F10>",
        F11 = "<F11>",
        F12 = "<F12>",
      },
    },

    -- Document existing key chains
    spec = {
      { "<leader>b", group = "[B]uffer" },
      { "<leader>c", group = "[C]omments (review)", mode = { "n", "x" } },
      { "<leader>d", group = "[D]iagnostics" },
      { "<leader>f", group = "[F]ind" },
      { "<leader>g", group = "[G]oto" },
      { "<leader>h", group = "[H]unk (git)" },
      { "<leader>t", group = "[T]abs" },
      { "<leader>w", group = "[W]indow" },
      { "<leader>o", group = "[O]rgmode" },
      { "<leader>q", group = "[Q]uickfix" },
      { "<leader>n", group = "[N]otes (Roam)" },
      { "<leader>r", group = "[R]efactor" },
      { "<leader>S", group = "[S]ession" },
      { "<leader>z", group = "[Z] Folds" },
      { "]", group = "Next" },
      { "[", group = "Prev" },
    },
  },
}
