-- Publish editor state to .nvim-state.org for an agent to read.
--
-- Lives in plugin/ rather than in the quickfix-review spec so it runs from
-- startup. Inside that spec it would only start once a review key had loaded
-- the plugin, which is exactly the session where nobody thought to press one.
--
-- See lua/custom/review-org.lua for the file's contents and its counterpart
-- .review.org.

local org = require("custom.review-org")

-- Diagnostics fire in bursts -- one LSP attach, one LaTeX build -- and each
-- would otherwise be a full rewrite.
local timer = nil

local function publish()
  if timer then
    timer:stop()
  end
  timer = vim.defer_fn(function()
    timer = nil
    -- Checked after the debounce rather than before: resolving the root walks
    -- the quickfix list and the directory tree, and this runs on every
    -- diagnostic change -- a burst of which is exactly what the debounce is
    -- for. Written only where a review is under way, so opening an unrelated
    -- project does not drop a file into it; :ReviewState is the way to get one
    -- anywhere else.
    if vim.fn.filereadable(org.path(org.REVIEW_FILE)) == 0 then
      return
    end
    pcall(org.write_state)
  end, 1000)
end

-- Synchronous, and deliberately not routed through `publish`: a debounced write
-- shares one timer with the autocmd, so any diagnostic arriving inside the
-- window would cancel this one and reschedule it under the autocmd's rule --
-- which declines to write where no review is in progress, the very case this
-- command exists for.
vim.api.nvim_create_user_command("ReviewState", function()
  vim.notify("Wrote " .. org.write_state())
end, { desc = "Review: write .nvim-state.org now" })

local group = vim.api.nvim_create_augroup("ReviewState", { clear = true })

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "QuickFixCmdPost", "BufWritePost" }, {
  group = group,
  callback = publish,
})

-- Fired by the review plugin on every write of .review.org, so the two files
-- appear together: adding a comment fires none of the editor events above, and
-- the first comment of a review is exactly when an agent starts reading.
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "ReviewExported",
  callback = publish,
})
