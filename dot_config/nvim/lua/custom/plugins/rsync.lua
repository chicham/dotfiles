-- Push, pull and diff the working tree against a remote host over rsync/scp,
-- configured per project by a `.nvim/deployment.lua` that `:TransferInit`
-- scaffolds. Loaded on its commands only: nothing here is wanted unless a
-- project actually has a remote to sync with.
return {
  "coffebar/transfer.nvim",
  lazy = true,
  cmd = { "TransferInit", "DiffRemote", "TransferUpload", "TransferDownload", "TransferDirDiff", "TransferRepeat" },
  opts = {},
}
