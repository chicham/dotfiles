-- gitsigns.nvim: inline git signs + hunk staging/preview/blame
-- Hunk navigation uses ]h / [h because ]c / [c are taken by the
-- treesitter class-motion mappings in init.lua.
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end

			-- Navigation (respects diff mode)
			map("n", "]h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gs.nav_hunk("next")
				end
			end, "Next git hunk")
			map("n", "[h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gs.nav_hunk("prev")
				end
			end, "Previous git hunk")

			-- Hunk actions. Stage/unstage maps are omitted: they write the git
			-- index, which jj ignores (jj snapshots the working tree, not the
			-- index). Reset reverts the working tree, so it is kept.
			map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
			map("v", "<leader>hr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Reset selected hunk")
			map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
			map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
			map("n", "<leader>hb", function()
				gs.blame_line({ full = true })
			end, "Blame line")
			map("n", "<leader>hd", gs.diffthis, "Diff against index")
			map("n", "<leader>hD", function()
				gs.diffthis("~")
			end, "Diff against last commit")

			-- Toggles
			map("n", "<leader>htb", gs.toggle_current_line_blame, "Toggle line blame")
			map("n", "<leader>htd", gs.toggle_deleted, "Toggle deleted")

			-- Text object
			map({ "o", "x" }, "ih", gs.select_hunk, "Select git hunk")
		end,
	},
}
