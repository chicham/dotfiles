return {
  "MMesch/quickfix-review-nvim",
  dependencies = { "ibhagwan/fzf-lua" },
  -- Comment list goes through fzf-lua instead of native :copen; the review
  -- comments still live in the real quickfix list underneath, so this just
  -- needs the list populated, not the plugin itself loaded.
  -- setup() is what installs the review maps, and setup() only runs once the
  -- plugin is loaded, so before the first load the keys do nothing and
  -- which-key has no descriptions to show under <leader>c. These entries give
  -- which-key the descriptions up front; the ones with no right-hand side let
  -- the first press load the plugin and then replay into the plugin's own map,
  -- so the behaviour stays owned upstream.
  keys = {
    {
      "<leader>co",
      function()
        require("fzf-lua").quickfix()
      end,
      desc = "Review: comment list (fzf)",
    },
    { "<leader>ca", mode = { "n", "x" }, desc = "Review: add comment (<Tab> cycles type)" },
    { "<leader>cd", mode = { "n", "x" }, desc = "Review: delete comment" },
    { "<leader>cv", desc = "Review: view comment" },
    { "<leader>cg", desc = "Review: go to real file" },
    { "<leader>cS", desc = "Review: summary" },
    { "<leader>cc", desc = "Review: clear all" },
    { "<leader>cR", "<cmd>ReviewResolutions<cr>", desc = "Review: proposed resolutions" },
    { "<leader>cI", "<cmd>ReviewImport<cr>", desc = "Review: import from .review.org" },
    { "]r", desc = "Next review comment" },
    { "[r", desc = "Prev review comment" },
  },
  cmd = {
    "ReviewAddIssue",
    "ReviewAddSuggestion",
    "ReviewAddNote",
    "ReviewAddPraise",
    "ReviewClear",
    "ReviewSummary",
    "ReviewGoto",
    "ReviewImport",
    "ReviewResolutions",
    "ReviewPublish",
  },
  -- The raw storage_file (:ReviewSave/:ReviewLoad) only holds bufnr, not
  -- filename, so it can't be read from outside the nvim session that wrote
  -- it. Agents read .review.org instead, which carries resolved paths and
  -- which they annotate in place; see lua/custom/review-org.lua for the
  -- format and for who owns which field.
  config = function()
    local qr = require("quickfix-review")
    local org = require("custom.review-org")

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
      local options = require("quickfix-review.config").options
      options.export_file = org.path(org.REVIEW_FILE)
      return options.export_file
    end

    qr.setup({
      export_file = (vim.fs.root(0, { ".jj", ".git" }) or vim.fn.getcwd()) .. "/" .. org.REVIEW_FILE,
      -- Default cycle_previous ('-') overwrites oil.nvim's global "open
      -- parent directory" map once this plugin's setup() runs.
      -- One type per thing the agent must do: fix it, weigh it, or answer it.
      -- `comment_types` replaces the plugin's six defaults rather than adding
      -- to them, so the picker offers only these.
      --
      -- Single-cell glyphs coloured by the same Diagnostic* groups the
      -- colourscheme gives difftastic, so a sign sits in the diff gutter
      -- without the ragged width of an emoji.
      comment_types = {
        issue = { sign = "!", highlight = "DiagnosticError", description = "Problems to fix" },
        suggestion = { sign = "~", highlight = "DiagnosticWarn", description = "Improvements" },
        question = { sign = "?", highlight = "DiagnosticInfo", description = "Clarification needed" },
      },
      keymaps = {
        -- One add key, <leader>ca, asks for the type (defined below), so the
        -- per-type maps and the type cycling are off.
        add_issue = false,
        add_suggestion = false,
        add_note = false,
        add_praise = false,
        add_question = false,
        add_insight = false,
        add_comment_cycle = false,
        cycle_next = false,
        cycle_previous = false,
        open_list = false, -- superseded by the fzf-lua `keys` binding above
        -- The clipboard export and the raw session file are superseded by
        -- .review.org, which survives restarts and carries resolved paths.
        export = false,
        save = false,
        load = false,
      },
    })

    -- Snapshot the current window and cursor; calling the result puts both
    -- back. The comment float takes focus, and closing it can leave the
    -- difftastic diff's cursor on line 1 instead of the line being commented,
    -- so it restores this snapshot when it closes.
    ---@return fun() restore
    local function save_cursor()
      local win = vim.api.nvim_get_current_win()
      local pos = vim.api.nvim_win_get_cursor(win)
      return function()
        if not vim.api.nvim_win_is_valid(win) then
          return
        end
        vim.api.nvim_set_current_win(win)
        local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win))
        pcall(vim.api.nvim_win_set_cursor, win, { math.min(pos[1], last), pos[2] })
        -- The diff folds unchanged stretches; keep the commented line visible.
        vim.cmd("normal! zv")
      end
    end

    -- <leader>ca: comment on the line or the selection. The type is chosen in
    -- the comment box itself (<Tab>), so nothing covers the line meanwhile.
    vim.keymap.set("n", "<leader>ca", function()
      qr.add_comment()
    end, { desc = "Review: add comment (<Tab> cycles type)" })
    vim.keymap.set("x", "<leader>ca", function()
      qr.add_comment_visual()
    end, { desc = "Review: add comment (<Tab> cycles type)" })

    -- Show the review comments where they apply: a gutter sign and, in the
    -- difftastic diff, the comment itself as a dimmed line under its row.
    --
    -- The diff buffer is a scratch copy whose rows are padded for alignment, so
    -- a comment's real-file line is mapped back to the row that shows it. A
    -- line with no row (removed since the diff was taken) is not drawn. Real
    -- file buffers get the plugin's own signs, which it only places on the
    -- buffer current at the time of an add.
    local inline_ns = vim.api.nvim_create_namespace("review-inline")
    local gap_ns = vim.api.nvim_create_namespace("review-gap")

    ---@param item table Quickfix item.
    ---@return string
    local function item_file(item)
      local name = item.filename or (item.bufnr and item.bufnr > 0 and vim.api.nvim_buf_get_name(item.bufnr)) or ""
      return vim.fn.fnamemodify(name, ":p")
    end

    ---@param aligned table[] Per-row `{ left_idx?, right_idx? }`, 0-indexed.
    ---@param line integer 1-indexed line of the working-copy file.
    ---@return integer? row 1-indexed row of the diff buffer.
    local function diff_row(aligned, line)
      for row, pair in ipairs(aligned) do
        if pair[2] and pair[2] + 1 == line then
          return row
        end
      end
    end

    local function draw_diff_comments()
      local ok, difft = pcall(require, "difftastic-nvim")
      local state = ok and difft.state or nil
      local buf = state and state.right_buf
      if not (buf and vim.api.nvim_buf_is_valid(buf)) then
        return
      end
      vim.api.nvim_buf_clear_namespace(buf, inline_ns, 0, -1)
      local file = state.files and state.files[state.current_file_idx]
      if not file or file.status == "deleted" then
        return
      end
      local path = vim.fn.fnamemodify(vim.fs.joinpath(state.root or "", file.path), ":p")
      local signs = require("quickfix-review.utils").sign_config
      local types = require("quickfix-review.config").options.comment_types

      -- Several comments on one row share one extmark: one sign, one virtual
      -- line each, in list order.
      local by_row = {}
      for _, item in ipairs(org.review_items()) do
        if item_file(item) == path then
          local row = diff_row(file.aligned_lines or {}, item.lnum)
          if row then
            by_row[row] = by_row[row] or {}
            table.insert(by_row[row], item)
          end
        end
      end

      local last = vim.api.nvim_buf_line_count(buf)
      for row, items in pairs(by_row) do
        if row <= last then
          local lines = {}
          local first_kind = items[1].text:match("^%[(%u+)") or "QUESTION"
          for _, item in ipairs(items) do
            local kind = item.text:match("^%[(%u+)") or "QUESTION"
            local cfg = types[kind:lower()] or {}
            local body = item.text:gsub("^%[[^%]]*%]%s*", "")
            lines[#lines + 1] = {
              { "    " .. (cfg.sign or "?") .. " " .. kind .. ": ", cfg.highlight or "Comment" },
              { body, "Comment" },
            }
          end
          local sign = signs[first_kind:lower()] or {}
          vim.api.nvim_buf_set_extmark(buf, inline_ns, row - 1, 0, {
            sign_text = #items > 1 and tostring(#items) or sign.text,
            sign_hl_group = sign.texthl,
            virt_lines = lines,
          })
        end
      end
    end

    ---@param bufnr integer
    local function draw_file_signs(bufnr)
      if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= "" then
        return
      end
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name == "" then
        return
      end
      pcall(require("quickfix-review.utils").refresh_buffer_signs, bufnr, vim.fn.fnamemodify(name, ":p"))
    end

    local function draw_comments()
      draw_diff_comments()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        draw_file_signs(bufnr)
      end
    end

    local inline_group = vim.api.nvim_create_augroup("ReviewInline", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = inline_group,
      pattern = "DifftRendered",
      callback = draw_diff_comments,
    })
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = inline_group,
      callback = function(args)
        draw_file_signs(args.buf)
      end,
    })
    -- The diff may already be on screen when the first review key loads this
    -- plugin, and comments imported before that have rows to draw.
    draw_comments()

    -- Keep .review.org current after every mutation, so an agent polling it
    -- always sees the latest state. `:ReviewExport` also copies to the `+`
    -- register, which would clobber the user's clipboard on every comment, so
    -- this writes the file directly instead of calling it.
    --
    -- Upstream's markdown export is bypassed entirely: it dumps the whole
    -- quickfix list, so every compiler diagnostic landing there -- a vimtex
    -- build fills it on each save -- reads as a review comment, and the
    -- "file empty" drain gate is never reachable. `org.export` filters to the
    -- plugin's own comments, and preserves the agent's annotations across the
    -- write.
    ---@return string? path `nil` once the list holds no review comment.
    local function write_export_file()
      local options = require("quickfix-review.config").options
      local stale = options.export_file
      local written = org.export(stale)
      options.export_file = written or resolve_export_file()
      -- .nvim-state.org is .review.org's counterpart, and an agent told to read
      -- one expects the other beside it. Only editor events produce it, and
      -- adding a comment fires none of them, so the first comment of a review
      -- would otherwise leave the agent with no editor state until the next
      -- build or save. plugin/review-state.lua listens for this.
      vim.api.nvim_exec_autocmds("User", { pattern = "ReviewExported" })
      draw_comments()
      return written
    end

    -- add_comment is replaced outright further down and exports itself, so
    -- it is not wrapped here.
    for _, fn_name in ipairs({ "delete_comment", "clear_review" }) do
      local original = qr[fn_name]
      qr[fn_name] = function(...)
        local result = { original(...) }
        write_export_file()
        return unpack(result)
      end
    end

    local qf_text = org.qf_text

    require("custom.review-publish").setup(write_export_file)

    -- Ask for comment text in a floating scratch buffer rather than the
    -- command line.
    --
    -- Upstream prompts with `vim.fn.input`, which is single-line, unstyled and
    -- outside `vim.ui.input`, so no ui plugin can reach it. A scratch buffer
    -- gives normal-mode editing, multi-line bodies and the buffer's own
    -- completion; joining the lines with a space on submit keeps the exported
    -- markdown one entry per line, which is the format agents parse.
    --
    -- With `kinds`, the title lists the comment types with the current one
    -- highlighted, and <Tab>/<S-Tab> cycle it; `on_submit` receives the type
    -- shown at submit time.
    ---@param title string Window title, e.g. "L12-14".
    ---@param on_submit fun(text: string, kind: string?)
    ---@param kinds? { list: string[], index: integer }
    local function prompt_float(title, on_submit, kinds)
      local restore = save_cursor()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].bufhidden = "wipe"
      vim.bo[buf].filetype = "markdown"

      local width = math.min(80, math.floor(vim.o.columns * 0.8))
      local height = 5

      -- The box sits in a gap of blank virtual lines opened under the
      -- commented line, so the text below moves down instead of being hidden.
      -- A line too close to the bottom is first scrolled to mid-window, so the
      -- gap fits on screen.
      local origin_buf = vim.api.nvim_get_current_buf()
      local origin_row = vim.api.nvim_win_get_cursor(0)[1] - 1
      local rows = height + 2
      if vim.fn.winline() + rows > vim.api.nvim_win_get_height(0) then
        vim.cmd("normal! zz")
      end
      -- Comments already drawn under the line come first; the box goes after.
      local shown = 0
      for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(origin_buf, inline_ns, { origin_row, 0 }, { origin_row, -1 }, { details = true })) do
        shown = shown + #(mark[4].virt_lines or {})
      end
      local blank = {}
      for i = 1, rows do
        blank[i] = { { "", "Normal" } }
      end
      local gap = vim.api.nvim_buf_set_extmark(origin_buf, gap_ns, origin_row, 0, { virt_lines = blank })
      -- Placed from the line's screen row once the gap is drawn: a
      -- cursor-relative float does not count the virtual lines in between.
      local origin_win = vim.api.nvim_get_current_win()
      vim.cmd("redraw")
      -- Editor rows are 0-indexed and screenpos is 1-indexed, so the line's
      -- screen row is already the editor row just below it.
      local line_pos = vim.fn.screenpos(origin_win, origin_row + 1, 1)

      local types = require("quickfix-review.config").options.comment_types
      local index = kinds and kinds.index or 1
      ---@return string|table
      local function title_chunks()
        if not kinds then
          return " " .. title .. " "
        end
        local chunks = { { " " } }
        for i, kind in ipairs(kinds.list) do
          if i > 1 then
            chunks[#chunks + 1] = { " · ", "FloatBorder" }
          end
          local cfg = types[kind:lower()] or {}
          if i == index then
            chunks[#chunks + 1] = { (cfg.sign or "") .. " " .. kind, cfg.highlight or "Title" }
          else
            chunks[#chunks + 1] = { kind:lower(), "Comment" }
          end
        end
        chunks[#chunks + 1] = { "  " .. title .. " ", "FloatTitle" }
        return chunks
      end

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = line_pos.row + shown,
        col = vim.fn.win_screenpos(origin_win)[2] - 1,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = title_chunks(),
        title_pos = "center",
        footer = kinds and " <Tab> type  <CR> submit  <Esc> cancel " or " <CR> submit  <Esc> cancel ",
        footer_pos = "center",
      })
      vim.wo[win].wrap = true

      local function close()
        -- <C-s> submits from insert mode, which would otherwise carry over
        -- into the window focus returns to.
        vim.cmd.stopinsert()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(origin_buf) then
          vim.api.nvim_buf_del_extmark(origin_buf, gap_ns, gap)
        end
        restore()
      end

      local function submit()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        close()
        local text = vim.trim(table.concat(lines, " "):gsub("%s+", " "))
        if text ~= "" then
          on_submit(text, kinds and kinds.list[index] or nil)
        end
      end

      if kinds then
        ---@param step integer
        local function cycle(step)
          index = (index - 1 + step) % #kinds.list + 1
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { title = title_chunks(), title_pos = "center" })
          end
        end
        -- Buffer-local, so they win over completion's insert-mode <Tab>.
        for _, mode in ipairs({ "n", "i" }) do
          vim.keymap.set(mode, "<Tab>", function()
            cycle(1)
          end, { buffer = buf, desc = "Next comment type" })
          vim.keymap.set(mode, "<S-Tab>", function()
            cycle(-1)
          end, { buffer = buf, desc = "Previous comment type" })
        end
      end

      vim.keymap.set("n", "<CR>", submit, { buffer = buf })
      vim.keymap.set("i", "<C-s>", submit, { buffer = buf })
      vim.keymap.set("n", "<Esc>", close, { buffer = buf })
      vim.keymap.set("n", "q", close, { buffer = buf })
      vim.cmd.startinsert()
    end

    -- Map a cursor row in difftastic's right pane to the line of the real file
    -- it shows. Filler rows have no counterpart, so they take the nearest row
    -- that does, searching upward first -- the rule difftastic's own `gf` uses.
    ---@param aligned table[] Per-row `{ left_idx?, right_idx? }`, 0-indexed.
    ---@param row integer 1-indexed row of the scratch buffer.
    ---@return integer line 1-indexed line of the working-copy file.
    local function difft_line(aligned, row)
      for offset = 0, #aligned do
        for _, r in ipairs({ row - offset, row + offset }) do
          local pair = aligned[r]
          if pair and pair[2] then
            return pair[2] + 1
          end
        end
      end
      return 1
    end

    -- Where a comment placed from the current window belongs. In the difftastic
    -- diff the buffer is a scratch copy, so the row is translated to the real
    -- file; a deleted file has no new version to anchor to. Elsewhere the
    -- buffer is the file already.
    ---@return string? file, fun(row: integer): integer line, boolean scratch
    local function comment_target()
      local ok, difft = pcall(require, "difftastic-nvim")
      local state = ok and difft.state or nil
      if not (state and state.right_win and vim.api.nvim_get_current_win() == state.right_win) then
        return require("quickfix-review.utils").get_real_filepath(),
          function(row)
            return row
          end,
          false
      end
      local file = state.files[state.current_file_idx]
      if not file or file.status == "deleted" then
        return nil, nil, true
      end
      return vim.fn.fnamemodify(vim.fs.joinpath(state.root or "", file.path), ":p"), function(row)
        return difft_line(file.aligned_lines or {}, row)
      end, true
    end

    -- Types in the order <Tab> walks them: most to least demanding of the
    -- agent. Any configured type not listed here follows, alphabetically.
    local KIND_ORDER = { "ISSUE", "SUGGESTION", "QUESTION" }
    local last_kind = KIND_ORDER[1]

    ---@return string[]
    local function kind_list()
      local configured = require("quickfix-review.config").options.comment_types
      local list, seen = {}, {}
      for _, kind in ipairs(KIND_ORDER) do
        if configured[kind:lower()] then
          list[#list + 1], seen[kind] = kind, true
        end
      end
      local rest = {}
      for name in pairs(configured) do
        if not seen[name:upper()] then
          rest[#rest + 1] = name:upper()
        end
      end
      table.sort(rest)
      return vim.list_extend(list, rest)
    end

    -- Replace the prompt half of add_comment, keeping its item shape. The range
    -- argument carries the same four forms upstream accepts. Without a type the
    -- box opens on the last type used, and <Tab> in the box changes it.
    qr.add_comment = function(comment_type, range)
      local qr_utils = require("quickfix-review.utils")
      if comment_type and not qr_utils.get_comment_type_config(comment_type) then
        vim.notify("Unknown comment type: " .. tostring(comment_type), vim.log.levels.ERROR)
        return
      end

      local file, to_line, scratch = comment_target()
      if not file then
        vim.notify("A deleted file has no new version to anchor a comment to", vim.log.levels.WARN)
        return
      end
      local start_line, end_line, start_col, end_col
      if range then
        start_line, end_line, start_col, end_col = range[1], range[2], range[3], range[4]
        if start_line > end_line then
          start_line, end_line = end_line, start_line
        end
      else
        start_line = vim.fn.line(".")
        end_line = start_line
      end
      start_line, end_line = to_line(start_line), to_line(end_line)
      -- Columns index the scratch row, which is padded for alignment.
      if scratch then
        start_col, end_col = nil, nil
      end

      local where = start_line == end_line and ("L" .. start_line) or ("L" .. start_line .. "-" .. end_line)
      local list = kind_list()
      local index = 1
      for i, k in ipairs(list) do
        if k == (comment_type and comment_type:upper() or last_kind) then
          index = i
        end
      end

      prompt_float(where, function(text, kind)
        last_kind = kind
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
        vim.fn.setqflist(items, "r")
        vim.fn.setqflist({}, "a", { title = "Code Review Comments" })

        if not scratch and not qr_utils.is_special_buffer() then
          pcall(qr_utils.refresh_buffer_signs, vim.fn.bufnr(), file)
        end
        write_export_file()
        vim.notify(kind .. " added to " .. vim.fn.fnamemodify(file, ":.") .. ":" .. start_line)
      end, { list = list, index = index })
    end

    -- Place signs for freshly imported comments, and report the ones that
    -- cannot take one.
    --
    -- A comment anchors to a line number, so a file edited since the export can
    -- leave one pointing past its end; placing a sign there throws. The comment
    -- is still imported -- it is the user's, and only they can decide where it
    -- now belongs -- but it is counted and reported, because a silently
    -- sign-less comment reads as a lost one.
    ---@param items table[]
    ---@return integer stale
    local function refresh_signs(items)
      local utils = require("quickfix-review.utils")
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
      return stale
    end

    -- Read .review.org back into the quickfix list.
    --
    -- :ReviewLoad cannot do this: it reads the raw storage file, which records
    -- buffer numbers rather than paths and so is meaningless outside the nvim
    -- session that wrote it. The org file holds resolved paths, which makes it
    -- the only form of a review that survives a restart -- or that an agent can
    -- hand back with its resolutions attached.
    vim.api.nvim_create_user_command("ReviewImport", function()
      local path = resolve_export_file()
      if vim.fn.filereadable(path) == 0 then
        vim.notify("No review comments at " .. path, vim.log.levels.WARN)
        return
      end

      local items = org.import()
      if #items == 0 then
        vim.notify("No comments parsed from " .. path, vim.log.levels.WARN)
        return
      end

      vim.fn.setqflist(items, "r")
      vim.fn.setqflist({}, "a", { title = "Code Review Comments" })

      local stale = refresh_signs(items)
      draw_diff_comments()
      local msg = string.format("Imported %d comments from %s", #items, path)
      if stale > 0 then
        msg = msg .. string.format(" (%d past the end of their file)", stale)
      end
      vim.notify(msg, stale > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
    end, { desc = "Review: import comments from .review.org" })

    -- Act on the resolutions the agent has proposed in .review.org.
    --
    -- The agent can only ever set a keyword left of the bar, so nothing it
    -- writes closes a comment. This is where a proposal becomes a decision:
    -- accepting deletes the comment, which is what empties the file and opens
    -- the drain gate; rejecting sends it back as REOPENED with a reply the
    -- agent reads on its next poll.
    --
    -- The pre-check is mechanical and advisory: it compares the anchored lines
    -- against the hash taken when the comment was first exported. Changed means
    -- the file moved where the comment points, which is evidence that the fix
    -- landed there -- not proof that it is right. Acceptance stays manual.
    vim.api.nvim_create_user_command("ReviewResolutions", function()
      local path = resolve_export_file()
      local root = org.root()
      local _, entries = org.import()

      local rows, by_label = {}, {}
      for id, entry in pairs(entries) do
        local keyword = entry.keyword
        if keyword and keyword ~= "TODO" and keyword ~= "REOPENED" then
          local props = entry.props
          local file = vim.fs.normalize(root .. "/" .. props.FILE)
          local lnum = tonumber(props.LINE) or 1
          local now = org.anchor_hash(file, lnum, tonumber(props.END_LINE) or lnum)
          local mark = "?"
          if now ~= "" and props.ANCHOR_HASH and props.ANCHOR_HASH ~= "" then
            mark = now ~= props.ANCHOR_HASH and "changed" or "UNCHANGED"
          end
          -- The id leads the row: it is what the agent reports its resolutions
          -- under in chat, and it is unique, which the rest of the row is not --
          -- two identical labels would collapse into one `by_label` entry.
          -- The row only has to identify the comment; the resolution and the
          -- reply, which are what gets weighed, are in the preview.
          local body = entry.body or ""
          if vim.fn.strchars(body) > 50 then
            body = vim.fn.strcharpart(body, 0, 49) .. "…"
          end
          local label = string.format(
            "%s  %-9s [%-9s] %s:%d  %s",
            id,
            keyword,
            mark,
            props.FILE,
            lnum,
            body
          )
          rows[#rows + 1] = label
          by_label[label] = { id = id, entry = entry, file = file, lnum = lnum, mark = mark }
        end
      end

      if #rows == 0 then
        vim.notify("No proposed resolutions in " .. path, vim.log.levels.INFO)
        return
      end
      table.sort(rows)

      -- The previewer goes to fzf-lua as a `_ctor` returning the class, never
      -- as the class itself: fzf-lua merges opts with `tbl_deep_extend`, which
      -- copies nested tables without their metatable, so a class passed
      -- directly arrives stripped of every inherited method. Functions survive
      -- the copy, and calling the class builds a real instance.
      -- `populate_preview_buf` receives the highlighted row, which `by_label`
      -- maps back to its comment.
      local builtin = require("fzf-lua.previewer.builtin")
      local ResolutionPreview = builtin.base:extend()
      function ResolutionPreview:populate_preview_buf(entry_str)
        local row = by_label[entry_str]
        if not row then
          return
        end
        local buf = self:get_tmp_buffer()
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, org.preview_lines(row.id, row.entry, root, row.mark))
        vim.bo[buf].filetype = "markdown"
        self:set_preview_buf(buf)
        self.win:update_preview_title(" " .. row.id .. " ")
        self.win:update_preview_scrollbar()
      end
      -- Comments and replies are single long lines in the org file; unwrapped,
      -- the preview would show as little of them as the row does.
      function ResolutionPreview:gen_winopts()
        return vim.tbl_extend("force", builtin.base.gen_winopts(self), { wrap = true, linebreak = true })
      end

      require("fzf-lua").fzf_exec(rows, {
        prompt = "Resolutions> ",
        previewer = {
          _ctor = function()
            return ResolutionPreview
          end,
        },
        fzf_opts = {
          ["--multi"] = true,
          ["--header"] = "enter accept   ctrl-r reopen   ctrl-o open   ctrl-d/ctrl-u scroll preview",
        },
        actions = {
          -- Accepting drops the comment from the quickfix list. The file is
          -- rebuilt from that list, so the heading goes with it -- which is
          -- what eventually empties the file and opens the drain gate. No
          -- keyword is written: DONE would be erased by the same rebuild.
          ["default"] = function(selected)
            local accepted = {}
            for _, label in ipairs(selected) do
              local row = by_label[label]
              if row then
                accepted[row.id] = true
              end
            end
            vim.fn.setqflist(
              vim.tbl_filter(function(item)
                return not (org.is_review_comment(item) and accepted[org.item_id(item, root)])
              end, vim.fn.getqflist()),
              "r"
            )
            -- Accepting the last comment removes the file, so re-importing
            -- would warn about its absence on the very action that opens the
            -- drain gate.
            local drained = write_export_file() == nil
            if not drained then
              vim.cmd("ReviewImport")
            end
            vim.notify(string.format(
              "Accepted %d resolution(s)%s",
              vim.tbl_count(accepted),
              drained and " -- review drained" or ""
            ))
          end,
          ["ctrl-r"] = function(selected)
            local row = by_label[selected[1]]
            if not row then
              return
            end
            prompt_float("Reopen " .. row.id, function(reply)
              org.annotate(path, row.id, "REOPENED", { REPLY = reply })
              vim.cmd("ReviewImport")
              vim.notify("Reopened " .. row.id .. " -- the agent sees it on its next poll")
            end)
          end,
          ["ctrl-o"] = function(selected)
            local row = by_label[selected[1]]
            if row then
              vim.cmd.edit(row.file)
              vim.api.nvim_win_set_cursor(0, { row.lnum, 0 })
            end
          end,
        },
      })
    end, { desc = "Review: accept or reopen proposed resolutions" })

  end,
}
