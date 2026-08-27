return {
  'tpope/vim-abolish',
  cmd = { 'Abolish', 'Subvert' },
  keys = {
    { 'cr', mode = { 'n', 'v' }, desc = 'Coerce case' },
  },
  -- vim-abolish's :S has no `inccommand` preview: it's a custom command and
  -- abolish registers no `-preview` callback, while Neovim only previews the
  -- builtin :substitute family. We define our own :S that delegates to :Subvert
  -- but adds a command-preview callback, so `:S/old/new/` shows the same live
  -- preview as builtin `:s`. Nvim auto-undoes the preview edits, so we reuse
  -- abolish's case-coercion verbatim instead of reimplementing it.
  --
  -- Defined in `init` (runs at startup) because preview must exist before you
  -- type the command. abolish itself stays lazy: the first :Subvert call (from
  -- either the preview or the real run) triggers its cmd-based load.
  init = function()
    local function spec(o)
      local range = ''
      if o.range == 2 then
        range = o.line1 .. ',' .. o.line2
      elseif o.range == 1 then
        range = tostring(o.line1)
      end
      return range .. 'Subvert' .. (o.bang and '!' or '') .. o.args
    end

    vim.api.nvim_create_user_command('S', function(o)
      vim.cmd(spec(o))
    end, {
      nargs = 1,
      bang = true,
      range = true,
      preview = function(o, _ns, _buf)
        -- On the very first use abolish may not be loaded yet; load it and skip
        -- preview for this one keystroke rather than loading a plugin mid-edit.
        if vim.fn.exists ':Subvert' ~= 2 then
          pcall(require('lazy').load, { plugins = { 'vim-abolish' } })
          return 0
        end
        pcall(function()
          vim.cmd('silent ' .. spec(o))
        end)
        return 2
      end,
    })
  end,
}
