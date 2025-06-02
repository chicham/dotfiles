-- Comprehensive Git integration for Neovim
return {
	"tpope/vim-fugitive",
	lazy = false,
	dependencies = {
		-- GitHub integration
		"tpope/vim-rhubarb",
		-- Git log and history viewer
		{
			"rbong/vim-flog",
			lazy = true,
			cmd = { "Flog", "Flogsplit", "Floggit" },
		},
		-- FZF integration for fuzzy finding
		"ibhagwan/fzf-lua",
		-- Git signs in the gutter
		{
			"lewis6991/gitsigns.nvim",
			opts = {
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				current_line_blame = false,
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol",
					delay = 500,
				},
				preview_config = {
					border = "rounded",
					style = "minimal",
				},
			},
		},
	},
	keys = {
		-- Status & Logs with enhanced Flog commands
		{ "<leader>gs", ":Floggit<CR>", desc = "Status window (Flog)" },
		{ "<leader>gl", ":Flog<CR>", desc = "Log graph (Flog)" },
		{ "<leader>gla", ":Flog -all<CR>", desc = "Log all branches (Flog)" },
		{ "<leader>glf", ":Flog -path=%<CR>", desc = "Log current file (Flog)" },
		{ "<leader>gls", ":Flog -search=", desc = "Search commit messages", silent = false },
		{ "<leader>glr", ":Flog -reflog<CR>", desc = "Show reflog (Flog)" },

		-- Advanced file history with FZF
		{ "<leader>gbl", function() require("fzf-lua").git_bcommits() end, desc = "Browse file log (FZF)" },

		-- Diff viewers
		{ "<leader>gd", ":Flogsplit -path=%<CR>", desc = "Diff file history (Flog)" },
		{ "<leader>gD", ":Flogsplit<CR>", desc = "Diff repo history (Flog)" },

		-- Staging operations
		{ "<leader>ga", function() require("gitsigns").stage_hunk() end, desc = "Add (stage) hunk" },
		{ "<leader>gA", function() require("gitsigns").stage_buffer() end, desc = "Add (stage) buffer" },
		{ "<leader>gw", ":Gwrite<CR>:e<CR>", desc = "Write & stage file" },

		-- Unstage and reset
		{ "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo stage hunk" },
		{ "<leader>gU", ":Git restore --staged %<CR>:e<CR>", desc = "Unstage file" },
		{ "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
		{ "<leader>gR", ":Git checkout -- %<CR>:e<CR>", desc = "Reset file" },

		-- Navigation between hunks
		{ "<leader>gj", function() require("gitsigns").nav_hunk("next") end, desc = "Next hunk" },
		{ "<leader>gk", function() require("gitsigns").nav_hunk("prev") end, desc = "Previous hunk" },
		-- Alternative standard ]c/[c navigation
		{ "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				require("gitsigns").nav_hunk("next")
			end
		end, desc = "Jump to next git change" },
		{ "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				require("gitsigns").nav_hunk("prev")
			end
		end, desc = "Jump to previous git change" },

		-- Branch management
		{ "<leader>gb", function() require("fzf-lua").git_branches() end, desc = "Browse branches (FZF)" },

		-- Enhanced commit operations
		{ "<leader>gc", ":Git commit<CR>", desc = "Commit changes" },
		{ "<leader>gC", ":Git commit --amend<CR>", desc = "Commit amend" },
		{ "<leader>gcf", ":Git commit --fixup=", desc = "Commit fixup", silent = false },

		-- Stash operations
		{ "<leader>gt", function() require("fzf-lua").git_stash() end, desc = "Browse stashes (FZF)" },
		{ "<leader>gts", ":Git stash<CR>:e<CR>", desc = "Stash changes" },
		{ "<leader>gtp", ":Git stash pop<CR>:e<CR>", desc = "Stash pop" },

		-- Rebase operations
		{ "<leader>gri", ":Git rebase -i ", desc = "Rebase interactive", silent = false },
		{ "<leader>grc", ":Git rebase --continue<CR>", desc = "Rebase continue" },
		{ "<leader>gra", ":Git rebase --abort<CR>", desc = "Rebase abort" },
		{ "<leader>grs", ":Git rebase --skip<CR>", desc = "Rebase skip" },
		{ "<leader>grf", ":Git rebase --autosquash<CR>", desc = "Rebase autosquash" },

		-- Remote operations
		{ "<leader>gf", ":Git fetch<CR>", desc = "Fetch changes" },
		{ "<leader>gp", ":Git push<CR>", desc = "Push changes" },
		{ "<leader>gP", ":Git push --force-with-lease<CR>", desc = "Push force-with-lease" },
		{ "<leader>gpl", ":Git pull<CR>", desc = "Pull changes" },

		-- Blame operations
		{ "<leader>gB", function() require("gitsigns").blame_line() end, desc = "Blame current line" },

		-- GitHub integration
		{
			"<leader>go",
			function()
				vim.cmd(string.format(".,GBrowse"))
			end,
			desc = "Open in GitHub",
			expr = true,
		},
		{
			"<leader>gO",
			function()
				vim.cmd("'<,'>GBrowse")
			end,
			desc = "Open selection in GitHub",
			mode = "v",
		},

		-- Preview and toggles
		{ "<leader>gh", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
		{ "<leader>gtb", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle blame" },
		{ "<leader>gtd", function() require("gitsigns").toggle_deleted() end, desc = "Toggle deleted" },

		-- Diff operations
		{ "<leader>gdd", function() require("gitsigns").diffthis() end, desc = "Diff against index" },
		{ "<leader>gdD", function() require("gitsigns").diffthis("@") end, desc = "Diff against last commit" },

		-- Visual mode selections
		{
			"<leader>ga",
			function()
				require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")})
			end,
			mode = "v",
			desc = "Add (stage) selected hunk"
		},
		{
			"<leader>gr",
			function()
				require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")})
			end,
			mode = "v",
			desc = "Reset selected hunk"
		},
	},
}
