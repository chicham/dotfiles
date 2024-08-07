return {
  "nvim-treesitter/nvim-treesitter",
  -- Do not works ?
  opts = {
    auto_install = true,
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      "c",
      "cpp",
      "go",
      "lua",
      "python",
      "rust",
      "vim",
      "bibtex",
      "comment",
      "dockerfile",
      "fish",
      "latex",
      "markdown",
      "markdown_inline",
      "proto",
      "regex",
      "rst",
      "toml",
      "org",
      "yaml",
    },
  },
}
