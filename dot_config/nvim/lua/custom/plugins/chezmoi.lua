-- Filetype and syntax for chezmoi source files. It overlaps nvim-chezmoi (see
-- nvim-chezmoi.lua), which resolves the filetype for most source files on its
-- own, but it covers two cases nvim-chezmoi does not:
--
--   * targets with no extension. nvim-chezmoi asks vim.filetype.match() about
--     the target name, so `private_config.tmpl` -> `config` matches nothing and
--     the buffer stays `template`; this plugin's path rules give it `conf`.
--   * the `.chezmoitmpl` compound filetype, which layers Go-template syntax
--     over the base one so `{{ .chezmoi.os }}` is highlighted inside a
--     template. nvim-chezmoi never produces a compound filetype.
--
-- It is filetype.vim plus two syntax files, no Lua at runtime, and measures at
-- 0.0ms to load.
return {
  "alker0/chezmoi.vim",
  -- Upstream requires this NOT be lazy-loaded for reliable filetype detection.
  lazy = false,
  init = function()
    -- This option is required.
    vim.g["chezmoi#use_tmp_buffer"] = true
    -- add other options here if needed.
  end,
}
