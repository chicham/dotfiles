return {
  "mbbill/undotree",
  config = function()
    vim.keymap.set("n", "U", vim.cmd.UndotreeToggle)
  end,
}
