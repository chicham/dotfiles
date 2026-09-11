return {
  'MMesch/quickfix-review-nvim',
  dependencies = { 'ibhagwan/fzf-lua' },
  -- Comment list goes through fzf-lua instead of native :copen; the review
  -- comments still live in the real quickfix list underneath, so this just
  -- needs the list populated, not the plugin itself loaded.
  keys = {
    { '<leader>co', function() require('fzf-lua').quickfix() end, desc = 'Review: comment list (fzf)' },
  },
  cmd = {
    'ReviewAddIssue',
    'ReviewAddSuggestion',
    'ReviewAddNote',
    'ReviewAddPraise',
    'ReviewDelete',
    'ReviewView',
    'ReviewExport',
    'ReviewClear',
    'ReviewSave',
    'ReviewLoad',
    'ReviewSummary',
    'ReviewGoto',
  },
  -- The raw storage_file (:ReviewSave/:ReviewLoad) only holds bufnr, not
  -- filename, so it can't be read from outside the nvim session that wrote
  -- it. :ReviewExport resolves real file:line refs, so agents must read that
  -- file instead.
  config = function()
    local qr = require('quickfix-review')

    -- Nearest '.jj' or '.git' from the current buffer, not plain cwd: a jj
    -- workspace (.workspaces/<name>) has its own '.jj' marker, so this lands
    -- the file at the workspace root when reviewing inside one, and at the
    -- main repo root otherwise -- correct in both layouts without needing to
    -- know which one nvim was opened in.
    local review_root = vim.fs.root(0, { '.jj', '.git' }) or vim.fn.getcwd()

    qr.setup({
      export_file = review_root .. '/.review-comments.md',
      -- Default cycle_previous ('-') overwrites oil.nvim's global "open
      -- parent directory" map once this plugin's setup() runs; <leader>ca/cr
      -- freed up on the LSP side (init.lua keeps <space>ca/<space>rn there).
      keymaps = {
        cycle_previous = '_',
        open_list = false, -- superseded by the fzf-lua `keys` binding above
      },
    })

    -- Keep .review-comments.md current after every mutation, so an agent
    -- polling it always sees the latest state. `:ReviewExport` also copies
    -- to the `+` register, which would clobber the user's clipboard on every
    -- comment, so this writes the file directly instead of calling it.
    local function write_export_file()
      local qr_config = require('quickfix-review.config')
      local path = qr_config.options.export_file
      if not path then return end

      local qf_list = vim.fn.getqflist()
      if #qf_list == 0 then
        os.remove(path)
        return
      end

      local content = require('quickfix-review.export').to_markdown(qf_list, qr_config.options)
      if not content then return end

      local f = io.open(path, 'w')
      if f then
        f:write(content)
        f:close()
      end
    end

    for _, fn_name in ipairs({ 'add_comment', 'delete_comment', 'clear_review' }) do
      local original = qr[fn_name]
      qr[fn_name] = function(...)
        local result = { original(...) }
        write_export_file()
        return unpack(result)
      end
    end
  end,
}
