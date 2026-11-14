-- difftastic as the diff view: structural, inline, with a file tree.
-- `difft` is also what jj (`ui.diff-formatter`) and git (`diff.external`)
-- use on the command line, so the terminal and the editor show the same diff.
--
-- The diff buffer is a scratch copy, not the file. quickfix-review.lua maps a
-- comment placed there to the line of the real file, and `gf` jumps to it.
--
-- `download = true` fetches the prebuilt binding instead of requiring a Rust
-- toolchain.
--
-- difftastic.nvim only draws side by side, so `inline` (on by default) folds
-- the left pane into the right one: a removed line takes the row difftastic
-- left as a filler, and the old text of a modified line is shown above it as
-- virtual text. Row count is unchanged, which is what keeps `gf` and the
-- comment mapping in quickfix-review.lua correct. The left window is closed,
-- and `state.left_win` aliases the right one so the plugin's own cursor and
-- focus code keeps working.
--
-- Unchanged stretches are folded (`CONTEXT` lines kept around each change, and
-- every function or class signature); `zo`/`zR` open them.
--
-- Launched through the fish `review` function ($REVIEW set), nvim starts with
-- an empty [No Name] tab and the diff opens in a second one. Once the diff is
-- up, that first tab is closed, and `q` then quits nvim since no other tab is
-- left to return to. `gf` and :DifftClose instead open a fresh tab first, so
-- closing the diff never closes the last tab.
local CONTEXT = 3

local SKIP = { "_type$", "_body$", "_list$", "_parameters$", "_arguments$", "_clause$", "_name$", "call", "identifier", "comment" }
local DEFS = { "function", "method", "class", "struct", "impl", "trait", "interface", "enum", "module", "namespace", "constructor" }

local function is_def(t)
  for _, p in ipairs(SKIP) do
    if t:find(p) then
      return false
    end
  end
  for _, p in ipairs(DEFS) do
    if t:find(p) then
      return true
    end
  end
  return false
end

--- Rows holding a function or class signature, which stay visible however far
--- they sit from a change: a folded stretch with no signature in it says
--- nothing about where in the file the change is.
---
--- The right side is parsed with filler rows blanked, so rows and buffer lines
--- stay aligned. A file with no parser gets no signatures and folds plainly.
---@return table<integer, boolean> keep Row numbers, 1-indexed.
local function def_rows(rows, file)
  local keep = {}
  local lines = {}
  for i, row in ipairs(rows) do
    lines[i] = row.right.is_filler and "" or row.right.content
  end
  local ok, tree = pcall(function()
    local ft = vim.filetype.match({ filename = vim.fn.fnamemodify(file.path, ":t") })
    local lang = ft and vim.treesitter.language.get_lang(ft)
    return lang and vim.treesitter.get_string_parser(table.concat(lines, "\n"), lang):parse()[1]
  end)
  if not ok or not tree then
    return keep
  end
  local function walk(node)
    if node:named() and is_def(node:type()) then
      local first = node:start()
      local body = node:field("body")[1]
      -- Rows up to the one before the body: a Python body starts on its first
      -- statement, a brace body on the signature's own line.
      local last = body and select(1, body:start()) or first
      last = math.max(last > first and last - 1 or first, first)
      for r = first, math.min(last, first + 8) do
        keep[r + 1] = true
      end
    end
    for child in node:iter_children() do
      walk(child)
    end
  end
  pcall(walk, tree:root())
  return keep
end

function _G.DifftFoldtext()
  return { { ("  ⋯ %d unchanged lines"):format(vim.v.foldend - vim.v.foldstart + 1), "Comment" } }
end

return {
  "clabby/difftastic.nvim",
  dependencies = { "MunifTanjim/nui.nvim", "folke/snacks.nvim" },
  cmd = { "Difft", "DifftPick", "DifftPickRange", "DifftClose" },
  opts = {
    download = true,
    vcs = "jj",
    -- ]] / [[ for hunks: in the scratch diff buffer their global meaning
    -- (LSP references) has nothing to act on. ]c / [c would shadow the
    -- treesitter class motions, and }} / {{ would make the paragraph
    -- motions wait out `timeoutlen`.
    keymaps = { next_hunk = "]]", prev_hunk = "[[" },
    snacks_picker = { enabled = true },
  },
  config = function(_, opts)
    local difft = require("difftastic-nvim")
    difft.setup(opts)

    local diff = require("difftastic-nvim.diff")
    local open_panes, render = diff.open, diff.render
    diff.open = function(state)
      -- File paths from the diff are relative to the repo root, not to the
      -- directory nvim was started in; remember the root so they can be opened.
      state.root = vim.fs.root(vim.uv.cwd(), { ".jj", ".git" }) or vim.uv.cwd()
      open_panes(state)
      local left = state.left_win
      -- The scratch buffer is wiped with its window; render still writes to it.
      vim.bo[state.left_buf].bufhidden = "hide"
      state.left_win = state.right_win
      vim.api.nvim_win_close(left, true)
      vim.api.nvim_set_current_win(state.right_win)
    end
    local inline_render
    -- `User DifftRendered` fires once the right pane shows `file`, so review
    -- comments (quickfix-review.lua) can be drawn onto the rows just written.
    diff.render = function(state, file)
      inline_render(state, file)
      -- Rendering sets the file's filetype on the diff buffer, and a filetype
      -- plugin may map the hunk keys for itself (python.vim maps ]] / [[ to
      -- its class motions), so they are set again after every render.
      local keys = difft.config.keymaps
      if vim.api.nvim_buf_is_valid(state.right_buf) then
        if keys.next_hunk then
          vim.keymap.set("n", keys.next_hunk, difft.next_hunk, { buffer = state.right_buf, desc = "Next hunk" })
        end
        if keys.prev_hunk then
          vim.keymap.set("n", keys.prev_hunk, difft.prev_hunk, { buffer = state.right_buf, desc = "Previous hunk" })
        end
      end
      vim.api.nvim_exec_autocmds("User", { pattern = "DifftRendered", modeline = false })
    end
    inline_render = function(state, file)
      render(state, file)
      local buf, ns = state.right_buf, vim.api.nvim_create_namespace("difft-inline")
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
      local rows = file.rows or {}
      if #rows == 0 then
        return
      end
      vim.bo[buf].modifiable = true
      for i, row in ipairs(rows) do
        local line = i - 1
        if row.right.is_filler and not row.left.is_filler then
          vim.api.nvim_buf_clear_namespace(buf, vim.api.nvim_create_namespace("difft-right"), line, line + 1)
          vim.api.nvim_buf_set_lines(buf, line, line + 1, false, { row.left.content })
          vim.api.nvim_buf_set_extmark(buf, ns, line, 0, { line_hl_group = "DifftRemovedLine" })
        elseif not row.left.is_filler and not row.right.is_filler and row.left.content ~= row.right.content then
          vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
            virt_lines = { { { row.left.content, "DifftRemovedLine" } } },
            virt_lines_above = true,
          })
        end
      end
      vim.bo[buf].modifiable = false

      -- Fold unchanged stretches, keeping CONTEXT lines around each change.
      -- origami's outline folds real code buffers by function and never sees
      -- these scratch buffers; what matters in a diff is distance from a
      -- change, not syntax. Folds hide rows without removing them, so row
      -- numbers, `gf` and comment mapping are unaffected.
      local function changed(row)
        return row.left.is_filler
          or row.right.is_filler
          or row.left.content ~= row.right.content
          or #(row.left.highlights or {}) > 0
          or #(row.right.highlights or {}) > 0
      end
      local near = def_rows(rows, file)
      for i, row in ipairs(rows) do
        if changed(row) then
          for j = math.max(1, i - CONTEXT), math.min(#rows, i + CONTEXT) do
            near[j] = true
          end
        end
      end
      vim.api.nvim_win_call(state.right_win, function()
        vim.wo.foldmethod = "manual"
        vim.wo.foldenable = true
        vim.wo.foldtext = "v:lua.DifftFoldtext()"
        vim.opt_local.fillchars:append({ fold = " " })
        vim.cmd("normal! zE")
        local start
        for i = 1, #rows + 1 do
          if i <= #rows and not near[i] then
            start = start or i
          elseif start then
            if i - start >= 2 then
              vim.cmd(("%d,%dfold"):format(start, i - 1))
            end
            start = nil
          end
        end
        vim.api.nvim_win_set_cursor(state.right_win, { 1, 0 })
      end)
    end

    local goto_file = difft.goto_file
    difft.goto_file = function()
      local state = difft.state
      local file = state.files[state.current_file_idx]
      if file and state.root then
        file.path = vim.fs.joinpath(state.root, file.path)
      end
      goto_file()
    end

    if not vim.env.REVIEW then
      return
    end

    -- difftastic.nvim switches back to the tab it was opened from, which was
    -- closed above. With the diff tab the only one, open an empty one first so
    -- the tabclose is legal and `gf` has somewhere to put the file.
    local close = difft.close
    difft.close = function()
      if #vim.api.nvim_list_tabpages() == 1 then
        vim.cmd.tabnew()
      end
      close()
    end

    local open = difft.open
    difft.open = function(...)
      -- A failed start (no repo, bad revset) leaves an empty editor with
      -- nothing to review, so quit non-zero; `review` prints the message once
      -- the terminal is back.
      local ok, err = pcall(open, ...)
      if not ok then
        local f = vim.env.REVIEW_ERR and io.open(vim.env.REVIEW_ERR, "w")
        if f then
          f:write((tostring(err):gsub("%s*stack traceback:.*", "")), "\n")
          f:close()
        end
        vim.cmd("cquit 1")
        return
      end
      -- The diff is built asynchronously, so wait for its tab to exist.
      local tries = 0
      local function drop_first_tab()
        local state = difft.state
        if state.diff_tabpage and state.original_tabpage then
          local original = state.original_tabpage
          state.original_tabpage = nil
          if vim.api.nvim_tabpage_is_valid(original) then
            vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(original))
          end
        elseif tries < 50 then
          tries = tries + 1
          vim.defer_fn(drop_first_tab, 100)
        end
      end
      drop_first_tab()

      -- `q` leaves the editor when the diff is all there is.
      local state = difft.state
      for _, buf in ipairs({ state.tree_buf, state.right_buf, state.left_buf }) do
        if buf and vim.api.nvim_buf_is_valid(buf) then
          vim.keymap.set("n", "q", function()
            if #vim.api.nvim_list_tabpages() == 1 then
              vim.cmd.qa()
            else
              difft.close()
            end
          end, { buffer = buf, desc = "Close diff" })
        end
      end
      if vim.env.REVIEW_NOTE and vim.env.REVIEW_NOTE ~= "" then
        vim.notify(vim.env.REVIEW_NOTE, vim.log.levels.WARN)
      end
    end
  end,
}
