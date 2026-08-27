-- nvim-origami: Quality-of-life folding plugin + treesitter-driven outline.
--
-- Auto-outline workflow:
--   Code files open already collapsed to an outline. You see every class AND all
--   its method signatures; each method/function collapses to a SINGLE line -- its
--   signature -- with the body folded away, plus comment blocks. No folding by hand.
--
--   Folding is SEMANTIC, decided by Treesitter, for ANY language with a parser:
--     * fold the WHOLE function / method node (the grammar's function-like types) --
--       never a class node, so all methods stay visible. The fold's anchor line is
--       the signature, so the function collapses to one line showing the signature;
--     * fold comment blocks (runs of >=2 comment lines) and docstrings everywhere.
--   Multi-line signatures would otherwise collapse to just their first physical
--   line; a custom foldtext (OrigamiSigFoldtext, below) reconstructs the full
--   signature onto one line so it stays readable.
--   Because we fold whole function nodes (not by nesting depth), a method folds the
--   same whether it is top-level or deep inside nested classes -- independent of its
--   fold level. The query is generated per language from the grammar's node types,
--   so it works everywhere without per-language config.
--
--   Navigation keymaps (init.lua):
--     <leader>zz  toggle the current function/method body (or all methods of a class)
--     <leader>za  toggle the entire file (collapse all <-> expand all)
--     <leader>zo  reset to the outline view
--   Plus origami's h/l (fold/unfold current line) and the standard za/zM/zR.
--
--   Caveat: a fold cannot start on line 1, so a comment block at the very top of
--   a file stays expanded (Neovim foldexpr limitation).

-- Prose/markup filetypes that should never auto-outline (open expanded).
local no_outline_ft = {
  markdown = true,
  markdown_inline = true,
  org = true,
  norg = true,
  text = true,
  help = true,
  vimdoc = true,
  gitcommit = true,
  gitrebase = true,
  tex = true,
  latex = true,
  bib = true,
  html = true,
  xml = true,
  rst = true,
  asciidoc = true,
  mail = true,
  man = true,
}

-- Runtime switch for the auto-outline behaviour, flipped by :OrigamiToggle
-- (defined in config). When off, apply_outline and force_treesitter_folds no-op,
-- so code buffers open fully expanded (foldlevel 99) like any prose file.
local outline_enabled = true

-- Build a SEMANTIC `folds` query for a language from its grammar:
--   (<function-like node> body: (_) @fold)   -- fold each function/method body
--   [ (comment) ... ]+ @fold                 -- fold runs of comments
-- Class/struct/etc. bodies are deliberately NOT matched (only function-like
-- types get a body pattern), so all methods stay visible. Returns nil when the
-- language has no function bodies to fold (e.g. json/yaml) -- those keep their
-- default folds and are left out of the outline entirely.
local function build_fold_query(lang)
  local ok, info = pcall(vim.treesitter.language.inspect, lang)
  if not ok or type(info) ~= 'table' or type(info.symbols) ~= 'table' then return nil end

  local has_body_field = false
  for _, f in ipairs(info.fields or {}) do
    if f == 'body' then has_body_field = true end
  end

  local fn_types, comment_types = {}, {}
  for name, named in pairs(info.symbols) do
    if named and not name:find('parameter') and not name:find('argument') then
      if name:find('func') or name:find('method') or name:find('constructor')
        or name:find('lambda') or name:find('closure') or name:find('arrow') then
        fn_types[#fn_types + 1] = name
      end
      if name:find('comment') then
        comment_types[#comment_types + 1] = name
      end
    end
  end

  -- A pattern is kept only if it compiles for this grammar. Validating each one
  -- in isolation drops "impossible" ones (e.g. a function-like type that has no
  -- `body` field) without throwing away the whole query.
  local function valid(pat)
    return pcall(vim.treesitter.query.parse, lang, pat)
  end

  local patterns = {}
  if has_body_field then
    table.sort(fn_types)
    for _, t in ipairs(fn_types) do
      -- Fold the WHOLE function/method node (not just its `body` field) so the
      -- fold's anchor line is the signature -- the function collapses to a single
      -- line showing its signature. Gated on has_body_field so we only fold
      -- function-likes that actually have a body (skips json/yaml etc.); a
      -- function whose body fits on one line simply won't fold (needs >=2 lines).
      local pat = '(' .. t .. ') @fold'
      if valid(pat) then patterns[#patterns + 1] = pat end
    end
  end
  if #comment_types > 0 then
    table.sort(comment_types)
    local alts = {}
    for _, c in ipairs(comment_types) do
      alts[#alts + 1] = '(' .. c .. ')'
    end
    local pat = (#alts == 1 and alts[1] or ('[' .. table.concat(alts, ' ') .. ']')) .. '+ @fold'
    if valid(pat) then patterns[#patterns + 1] = pat end
  end
  -- Fold docstrings: a bare string statement (module/class/function docstring in
  -- Python, etc.). Strings aren't comment nodes, so they need their own pattern.
  do
    local pat = '(expression_statement (string) @fold)'
    if valid(pat) then patterns[#patterns + 1] = pat end
  end
  if #patterns == 0 then return nil end

  return table.concat(patterns, '\n')
end

-- lang -> true (customized) / false (left on defaults). Caches so inspect +
-- query.set run once per language.
local fold_query_done = {}
local function ensure_fold_query(lang)
  if fold_query_done[lang] == nil then
    local query = build_fold_query(lang)
    if query then pcall(vim.treesitter.query.set, lang, 'folds', query) end
    fold_query_done[lang] = query ~= nil
  end
  return fold_query_done[lang]
end

local function buf_lang(buf)
  local ft = vim.bo[buf].filetype
  if ft == '' or no_outline_ft[ft] then return nil end
  return vim.treesitter.language.get_lang(ft) or ft
end

-- Force Treesitter as the fold provider (over origami's LSP-folds preference) so
-- our custom semantic query actually drives folding.
local function force_treesitter_folds(buf)
  if not outline_enabled then return end
  local lang = buf_lang(buf)
  if not lang or not ensure_fold_query(lang) then return end
  local win = vim.fn.bufwinid(buf)
  if win == -1 then return end
  vim.api.nvim_win_call(win, function()
    if vim.wo.foldexpr ~= 'v:lua.vim.treesitter.foldexpr()' then
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
  end)
  vim.b[buf].origami_folding_provider = 'treesitter'
end

-- With the semantic query, function/method bodies and comment runs are the only
-- folds, so foldlevel 0 collapses them all -> classes show every method, bodies
-- and comments folded, everywhere, regardless of nesting.
local OUTLINE_FOLDLEVEL = 0

local function apply_outline(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not outline_enabled then return end
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.b[buf].origami_outlined then return end -- only on first open, never on re-entry
  local lang = buf_lang(buf)
  if not lang or not ensure_fold_query(lang) then return end -- only code we customized
  local win = vim.fn.bufwinid(buf)
  if win == -1 then return end
  force_treesitter_folds(buf)
  vim.b[buf].origami_outlined = true
  vim.api.nvim_win_call(win, function()
    vim.wo[win].foldlevel = OUTLINE_FOLDLEVEL
    -- zx forces the foldexpr provider to (re)compute folds and re-applies
    -- foldlevel, which is what actually collapses the bodies on open.
    pcall(vim.cmd, 'normal! zx')
  end)
end

-- Foldtext for the outline. Because we fold the whole function node, a multi-line
-- signature would otherwise show only its first physical line (e.g. `def foo(`).
-- This reconstructs the full signature onto one line: it finds the node that
-- starts on the fold's first line and has a `body` field beginning on a LATER line,
-- then joins everything from the header down to (but excluding) the body, collapsing
-- whitespace. Docstrings/first statements live INSIDE the body, so they are never
-- pulled in. Falls back to the raw first line for non-function folds (comments).
function _G.OrigamiSigFoldtext()
  local buf = vim.api.nvim_get_current_buf()
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local row = fs - 1
  local first = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ''
  local indent = first:match('^%s*') or ''
  local text = vim.trim(first)

  local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf, pos = { row, #indent } })
  if ok and node then
    while node do
      if node:start() == row then
        local bok, bf = pcall(function() return node:field('body') end)
        if bok and bf and bf[1] then
          local brow, bcol = bf[1]:start()
          if brow > row then
            -- Take the header lines up to the body's start COLUMN on its start row,
            -- not the whole row. For brace languages the body block begins at the
            -- `{`, which often shares the signature's last line (`) -> bool {`);
            -- truncating at bcol keeps `) -> bool ` and drops only the `{`. For
            -- colon-block languages (Python/Lua) bcol is the first statement's
            -- indent, so the truncated last line is whitespace and trims away.
            local lines = vim.api.nvim_buf_get_lines(buf, row, brow + 1, false)
            lines[#lines] = lines[#lines]:sub(1, bcol)
            local parts = {}
            for _, sl in ipairs(lines) do
              local t = vim.trim(sl)
              if t ~= '' then parts[#parts + 1] = t end
            end
            text = table.concat(parts, ' ')
            break
          end
        end
      end
      node = node:parent()
    end
  end

  -- Cosmetic: tidy the spacing that line-joining leaves around brackets/commas,
  -- and drop a trailing body-opening brace (the single-line-signature fallback).
  text = text:gsub('%(%s+', '('):gsub('%s+%)', ')'):gsub('%s+,', ','):gsub(',%s*%)', ')')
  text = text:gsub('%s*{%s*$', '')

  return {
    { indent .. text },
    { '  ' },
    { '󰁂 ' .. (fe - fs + 1) .. ' lines', 'Comment' },
  }
end

return {
  'chrisgrieser/nvim-origami',
  event = 'VeryLazy',

  -- Windows start fully expanded; apply_outline collapses code buffers.
  init = function()
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
  end,

  opts = {
    useLspFoldsWithTreesitterFallback = { enabled = true },
    pauseFoldsOnSearch = true,
    -- We own foldtext (OrigamiSigFoldtext) so multi-line signatures are
    -- reconstructed onto one line; origami's own foldtext is left off.
    foldtext = { enabled = false },
    -- Body + comment folding is driven by the treesitter query above; origami's
    -- own LSP-kind autoFold is left off to avoid fighting it.
    autoFold = { enabled = false },
    foldKeymaps = { setup = true }, -- h/l/^/$ overloads
  },

  config = function(_, opts)
    require('origami').setup(opts)

    -- Reconstruct full (possibly multi-line) signatures in folded outlines.
    vim.o.foldtext = 'v:lua.OrigamiSigFoldtext()'

    local grp = vim.api.nvim_create_augroup('origami-auto-outline', { clear = true })

    -- Toggle the auto-outline at runtime. When turning off, open every fold so
    -- nothing is left collapsed; when turning on, clear the per-buffer "already
    -- outlined" guard and re-outline every listed buffer.
    vim.api.nvim_create_user_command('OrigamiToggle', function()
      outline_enabled = not outline_enabled
      if outline_enabled then
        for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
          vim.b[b.bufnr].origami_outlined = nil
          apply_outline(b.bufnr)
        end
      else
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          vim.api.nvim_win_call(win, function() pcall(vim.cmd, 'normal! zR') end)
        end
      end
      vim.notify('Origami auto-outline ' .. (outline_enabled and 'enabled' or 'disabled'))
    end, { desc = 'Toggle origami auto-outline' })

    -- Keep Treesitter as the fold provider for code languages. Runs after
    -- origami's own FileType/LspAttach handlers (registered above in setup), so
    -- it wins even when an LSP attaches and tries to take over folding.
    vim.api.nvim_create_autocmd({ 'FileType', 'LspAttach' }, {
      group = grp,
      callback = function(ev)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then force_treesitter_folds(ev.buf) end
        end)
      end,
    })

    -- Collapse to the outline when a code buffer is first read.
    vim.api.nvim_create_autocmd({ 'FileType', 'BufReadPost' }, {
      group = grp,
      callback = function(ev)
        vim.schedule(function() apply_outline(ev.buf) end)
      end,
    })

    -- Cover the buffer already open when origami lazy-loads (VeryLazy).
    for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
      apply_outline(b.bufnr)
    end
  end,
}
