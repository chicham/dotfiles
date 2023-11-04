return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      pickers = {
        find_files = {
          theme = " dropdown",
        },
      },
    },
  },
  keys = {
    {
      "g/",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end,
    },
    {
      "g*",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end,
    },
    { "<leader>fb", require("telescope.builtin").buffers, { desc = "Search [B]uffers" } },
    { "<leader>fh", require("telescope.builtin").help_tags, { desc = "Search [H]elp" } },
    { "<leader>fG", require("telescope.builtin").live_grep, { desc = "Search by [G]rep" } },
    { "<leader>fD", require("telescope.builtin").diagnostics, { desc = "Search [D]iagnostics" } },
    { "<leader>fq", require("telescope.builtin").quickfix, { desc = "Search [Q]uickfix" } },
    { "<leader>fw", require("telescope.builtin").lsp_dynamic_workspace_symbols, { desc = "[W]orkspace Symbols" } },
    { "<leader>fm", require("telescope.builtin").marks, { desc = "Find [M]arks" } },
    { "<leader>fr", require("telescope.builtin").lsp_references, { desc = "Find [R]eferences" } },
    { "<leader>fk", require("telescope.builtin").keymaps, { desc = "Search [K]eymaps" } },
    { "<leader>fc", require("telescope.builtin").command_history, { desc = "Find [C]ommands" } },
    { "gd", require("telescope.builtin").lsp_definitions, { desc = "[G]oto [D]efinition" } },
    {
      "<leader>ff",
      function(opts)
        opts = opts or {}
        opts.cwd = vim.fn.systemlist("git root")[1]
        require("telescope.builtin").find_files(opts)
      end,
      { desc = "Search [F]iles" },
    },
    {
      "<leader>fd",
      function()
        require("telescope.builtin").diagnostics({ bufnr = 0 })
      end,
      { desc = "Search [D]iagnostics" },
    },
    {
      "<leader>fs",
      function()
        require("telescope.builtin").lsp_document_symbols({
          symbols = { "class", "method", "function", "module", "variable", "constant" },
        })
      end,
      { desc = "Document [S]ymbols" },
    },
    { "<leader><leader>", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" } },
  },
}
