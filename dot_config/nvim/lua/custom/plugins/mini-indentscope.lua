-- Current-indent-scope visualizer + matching text objects (standalone mini
-- module). Replaces indent-blankline's `scope` highlight: ibl's scope is
-- treesitter-based and coarse (in Python it highlights the whole enclosing
-- function), whereas mini.indentscope's scope is indentation-based and fine
-- (the actual current indent block) — and it ships text objects computed from
-- the *same* scope it draws, so "what you see highlighted" == "what ii/ai
-- selects".
--
-- ii = inner scope (body lines), ai = scope + its border (the header line,
-- e.g. the `def`/`if` line). [i/]i are intentionally NOT mapped here — those
-- stay on the @conditional treesitter moves defined in init.lua.
--
-- The scope line is recoloured per indentation depth to mimic rainbow-
-- delimiters (the look ibl gave via scope_highlight_from_extmark). Note this
-- keys off indentation depth, not the actual bracket extmark, so the colour at
-- a given line may differ from what ibl showed for bracketed code.

return {
  'echasnovski/mini.indentscope',
  version = false,
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local mi = require 'mini.indentscope'

    mi.setup {
      symbol = '┊', -- same glyph as the ibl indent guides
      -- Static (no growth animation), to match ibl's scope cue.
      draw = { animation = function()
        return 0
      end },
      options = { try_as_border = true },
      mappings = {
        object_scope = 'ii',
        object_scope_with_border = 'ai',
        -- Disabled: keep [i/]i bound to the @conditional moves (init.lua).
        goto_top = '',
        goto_bottom = '',
      },
    }

    -- Rainbow-by-depth: relink the scope symbol's highlight to a
    -- RainbowDelimiter* group based on the current scope's indentation depth.
    -- Extmarks resolve their highlight by name at redraw, so updating the link
    -- recolours the already-drawn line.
    local rainbow = {
      'RainbowDelimiterRed',
      'RainbowDelimiterYellow',
      'RainbowDelimiterBlue',
      'RainbowDelimiterOrange',
      'RainbowDelimiterGreen',
      'RainbowDelimiterViolet',
      'RainbowDelimiterCyan',
    }
    local function update_hl()
      local ok, scope = pcall(mi.get_scope)
      if not ok or not scope or not scope.body then
        return
      end
      local sw = vim.fn.shiftwidth()
      if sw < 1 then
        sw = 1
      end
      local level = math.floor((scope.body.indent or 0) / sw)
      local idx = ((math.max(level, 1) - 1) % #rainbow) + 1
      vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { link = rainbow[idx] })
    end

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'WinEnter' }, {
      group = vim.api.nvim_create_augroup('MiniIndentscopeRainbow', { clear = true }),
      callback = vim.schedule_wrap(update_hl),
    })
  end,
}
