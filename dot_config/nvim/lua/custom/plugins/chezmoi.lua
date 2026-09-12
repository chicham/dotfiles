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
