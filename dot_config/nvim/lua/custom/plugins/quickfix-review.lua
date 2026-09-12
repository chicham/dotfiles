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
    'ReviewImport',
  },
  -- The raw storage_file (:ReviewSave/:ReviewLoad) only holds bufnr, not
  -- filename, so it can't be read from outside the nvim session that wrote
  -- it. :ReviewExport resolves real file:line refs, so agents must read that
  -- file instead.
  config = function()
    local qr = require('quickfix-review')

    -- Point `export_file` at the repo holding the file under review, and keep
    -- it pointed there as the review moves between repos.
    --
    -- The root is the nearest '.jj' or '.git' rather than the cwd: a jj
    -- workspace (.workspaces/<name>) carries its own '.jj' marker, so a review
    -- taken inside one lands at the workspace root and one taken in the main
    -- checkout lands at the repo root, without either layout having to be
    -- declared. It is derived from the first comment in the list when there is
    -- one -- that comment names the file the review is about -- and from the
    -- current buffer otherwise, which is the file about to be commented on.
    --
    -- Resolving it per call rather than once is what makes that true. nvim
    -- loads this plugin from whatever buffer first pressed a review key, which
    -- need not be, and often is not, in the repo the user goes on to review;
    -- a root frozen at load time silently exports every later comment into the
    -- first repo, where the agent polling the workspace never sees it.
    ---@return string
    local function resolve_export_file()
      local options = require('quickfix-review.config').options

      local anchor
      local first = vim.fn.getqflist()[1]
      if first and first.bufnr and first.bufnr ~= 0 then
        anchor = vim.api.nvim_buf_get_name(first.bufnr)
      end
      if not anchor or anchor == '' then
        anchor = vim.api.nvim_buf_get_name(0)
      end

      local root = (anchor ~= '' and vim.fs.root(anchor, { '.jj', '.git' }))
        or vim.fs.root(0, { '.jj', '.git' })
        or vim.fn.getcwd()

      options.export_file = root .. '/.review-comments.md'
      return options.export_file
    end

    qr.setup({
      export_file = (vim.fs.root(0, { '.jj', '.git' }) or vim.fn.getcwd()) .. '/.review-comments.md',
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

      -- An emptied list deletes the file that was last written, so the stale
      -- path is the right one here; re-resolving would leave it behind and
      -- delete nothing.
      local qf_list = vim.fn.getqflist()
      if #qf_list == 0 then
        if qr_config.options.export_file then os.remove(qr_config.options.export_file) end
        return
      end

      local path = resolve_export_file()

      local content = require('quickfix-review.export').to_markdown(qf_list, qr_config.options)
      if not content then return end

      local f = io.open(path, 'w')
      if f then
        f:write(content)
        f:close()
      end
    end

    -- add_comment is replaced outright further down and exports itself, so
    -- it is not wrapped here.
    for _, fn_name in ipairs({ 'delete_comment', 'clear_review' }) do
      local original = qr[fn_name]
      qr[fn_name] = function(...)
        local result = { original(...) }
        write_export_file()
        return unpack(result)
      end
    end

    -- Split the `path:line` reference an exported comment carries back into a
    -- path and a position. Four shapes exist, and they are ambiguous with each
    -- other from the left, so they are matched longest-first.
    ---@param ref string
    ---@return string? file, integer? lnum, integer? end_lnum, integer? col, integer? end_col
    local function parse_ref(ref)
      local file, lnum, col, end_lnum, end_col = ref:match('^(.*):(%d+):(%d+)%-(%d+):(%d+)$')
      if file then return file, tonumber(lnum), tonumber(end_lnum), tonumber(col), tonumber(end_col) end

      file, lnum, col, end_col = ref:match('^(.*):(%d+):(%d+)%-(%d+)$')
      if file then return file, tonumber(lnum), tonumber(lnum), tonumber(col), tonumber(end_col) end

      file, lnum, end_lnum = ref:match('^(.*):(%d+)%-(%d+)$')
      if file then return file, tonumber(lnum), tonumber(end_lnum), nil, nil end

      file, lnum = ref:match('^(.*):(%d+)$')
      if file then return file, tonumber(lnum), tonumber(lnum), nil, nil end

      return nil
    end

    -- Rebuild the `[TYPE...]` prefix the plugin stores in the quickfix text, so
    -- that a re-export of an imported comment is identical to the line it came
    -- from.
    ---@param kind string Upper-case comment type.
    ---@param lnum integer
    ---@param end_lnum integer
    ---@param col integer?
    ---@param end_col integer?
    ---@param text string
    ---@return string
    local function qf_text(kind, lnum, end_lnum, col, end_col, text)
      if col and end_col then
        if lnum ~= end_lnum then
          return string.format('[%s:L%d:%d-L%d:%d] %s', kind, lnum, col, end_lnum, end_col, text)
        end
        return string.format('[%s:L%d:%d-%d] %s', kind, lnum, col, end_col, text)
      elseif lnum ~= end_lnum then
        return string.format('[%s:L%d-%d] %s', kind, lnum, end_lnum, text)
      end
      return string.format('[%s] %s', kind, text)
    end

    -- Ask for comment text in a floating scratch buffer rather than the
    -- command line.
    --
    -- Upstream prompts with `vim.fn.input`, which is single-line, unstyled and
    -- outside `vim.ui.input`, so no ui plugin can reach it. A scratch buffer
    -- gives normal-mode editing, multi-line bodies and the buffer's own
    -- completion; joining the lines with a space on submit keeps the exported
    -- markdown one entry per line, which is the format agents parse.
    ---@param title string Window title, e.g. "ISSUE comment (L12-14)".
    ---@param on_submit fun(text: string)
    local function prompt_float(title, on_submit)
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].bufhidden = 'wipe'
      vim.bo[buf].filetype = 'markdown'

      local width = math.min(80, math.floor(vim.o.columns * 0.8))
      local win = vim.api.nvim_open_win(buf, true, {
        relative = 'cursor',
        row = 1,
        col = 0,
        width = width,
        height = 5,
        style = 'minimal',
        border = 'rounded',
        title = ' ' .. title .. ' ',
        title_pos = 'center',
        footer = ' <CR> submit  <Esc> cancel ',
        footer_pos = 'center',
      })
      vim.wo[win].wrap = true

      local function close()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end

      local function submit()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        close()
        local text = vim.trim(table.concat(lines, ' '):gsub('%s+', ' '))
        if text ~= '' then
          on_submit(text)
        end
      end

      vim.keymap.set('n', '<CR>', submit, { buffer = buf })
      vim.keymap.set('i', '<C-s>', submit, { buffer = buf })
      vim.keymap.set('n', '<Esc>', close, { buffer = buf })
      vim.keymap.set('n', 'q', close, { buffer = buf })
      vim.cmd.startinsert()
    end

    -- Replace the prompt half of add_comment, keeping its item shape. The range
    -- argument carries the same four forms upstream accepts.
    qr.add_comment = function(comment_type, range)
      local qr_utils = require('quickfix-review.utils')
      if not qr_utils.get_comment_type_config(comment_type) then
        vim.notify('Unknown comment type: ' .. tostring(comment_type), vim.log.levels.ERROR)
        return
      end

      local file = qr_utils.get_real_filepath()
      local start_line, end_line, start_col, end_col
      if range then
        start_line, end_line, start_col, end_col = range[1], range[2], range[3], range[4]
        if start_line > end_line then
          start_line, end_line = end_line, start_line
        end
      else
        start_line = vim.fn.line('.')
        end_line = start_line
      end

      local kind = comment_type:upper()
      local where = start_line == end_line and ('L' .. start_line)
        or ('L' .. start_line .. '-' .. end_line)

      prompt_float(kind .. ' ' .. where, function(text)
        local items = vim.fn.getqflist()
        items[#items + 1] = {
          filename = file,
          lnum = start_line,
          end_lnum = end_line,
          col = start_col or 1,
          end_col = end_col,
          text = qf_text(kind, start_line, end_line, start_col, end_col, text),
          type = kind:sub(1, 1),
        }
        vim.fn.setqflist(items, 'r')
        vim.fn.setqflist({}, 'a', { title = 'Code Review Comments' })

        if not qr_utils.is_special_buffer() then
          pcall(qr_utils.refresh_buffer_signs, vim.fn.bufnr(), file)
        end
        write_export_file()
        vim.notify(kind .. ' added to ' .. vim.fn.fnamemodify(file, ':.') .. ':' .. start_line)
      end)
    end

    -- Read the export file back into the quickfix list.
    --
    -- :ReviewLoad cannot do this: it reads the raw storage file, which records
    -- buffer numbers rather than paths and so is meaningless outside the nvim
    -- session that wrote it. The export file holds resolved `path:line`
    -- references, which makes it the only form of a review that survives a
    -- restart -- or that an agent can hand back.
    --
    -- Paths are resolved against the export file's directory, which is the
    -- workspace root, rather than the cwd: the export wrote them relative to
    -- wherever nvim happened to be.
    vim.api.nvim_create_user_command('ReviewImport', function()
      local path = resolve_export_file()
      local f = io.open(path, 'r')
      if not f then
        vim.notify('No review comments at ' .. tostring(path), vim.log.levels.WARN)
        return
      end
      local content = f:read('*a')
      f:close()

      local base = vim.fn.fnamemodify(path, ':h')
      local items = {}
      for line in content:gmatch('[^\n]+') do
        local kind, ref, text = line:match('^%d+%.%s+%*%*%[(%u+)%]%*%*%s+`([^`]+)`%s+%-%s+(.*)$')
        if kind then
          local file, lnum, end_lnum, col, end_col = parse_ref(ref)
          if file then
            items[#items + 1] = {
              filename = vim.fs.normalize(base .. '/' .. file),
              lnum = lnum,
              end_lnum = end_lnum,
              col = col or 1,
              end_col = end_col,
              text = qf_text(kind, lnum, end_lnum, col, end_col, text),
              type = kind:sub(1, 1),
            }
          end
        end
      end

      if #items == 0 then
        vim.notify('No comments parsed from ' .. path, vim.log.levels.WARN)
        return
      end

      vim.fn.setqflist(items, 'r')
      vim.fn.setqflist({}, 'a', { title = 'Code Review Comments' })

      -- A comment anchors to a line number, so a file edited since the export
      -- can leave one pointing past its end; placing a sign there throws. The
      -- comment is still imported -- it is the user's, and only they can decide
      -- where it now belongs -- but it is counted and reported, because a
      -- silently sign-less comment reads as a lost one.
      local utils = require('quickfix-review.utils')
      local refreshed, stale = {}, 0
      for _, item in ipairs(items) do
        local bufnr = vim.fn.bufnr(item.filename)
        if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
          if item.lnum > vim.api.nvim_buf_line_count(bufnr) then
            stale = stale + 1
          elseif not refreshed[bufnr] then
            refreshed[bufnr] = true
            pcall(utils.refresh_buffer_signs, bufnr, item.filename)
          end
        end
      end

      local msg = string.format('Imported %d comments from %s', #items, path)
      if stale > 0 then
        msg = msg .. string.format(' (%d past the end of their file)', stale)
      end
      vim.notify(msg, stale > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
    end, { desc = 'Review: import comments from the export file' })
  end,
}
