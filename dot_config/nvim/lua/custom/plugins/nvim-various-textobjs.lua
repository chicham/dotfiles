return {
  "https://github.com/chrisgrieser/nvim-various-textobjs",
  opts = { useDefaultKeymaps = false },
  config = function()
    -- example: `?` for diagnostic textobj
    vim.keymap.set({ "o", "x" }, "ad", "<cmd>lua require(\"various-textobjs\").diagnostic()<CR>")
    vim.keymap.set({ "o", "x" }, "a|", "<cmd>lua require('various-textobjs').column()<CR>")

    -- example: `an` for outer subword, `in` for inner subword
    vim.keymap.set({ "o", "x" }, "as", "<cmd>lua require(\"various-textobjs\").subword(false)<CR>", { remap = true })
    vim.keymap.set({ "o", "x" }, "is", "<cmd>lua require(\"various-textobjs\").subword(true)<CR>", { remap = true })
    vim.keymap.set({ "o", "x" }, "av", "<cmd>lua require('various-textobjs').value(true)<CR>")
    vim.keymap.set({ "o", "x" }, "iv", "<cmd>lua require('various-textobjs').value(false)<CR>")
    vim.keymap.set({ "o", "x" }, "ak", "<cmd>lua require('various-textobjs').key(true)<CR>")
    vim.keymap.set({ "o", "x" }, "ik", "<cmd>lua require('various-textobjs').key(false)<CR>")
  end,
}
