-- fzf-lua.lua
-- Fast and powerful fuzzy finder using FZF
return {
	"ibhagwan/fzf-lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- Optional for file icons
	},
	config = function()
		local fzf = require("fzf-lua")

		-- Setup fzf-lua with telescope-like UI
		fzf.setup({
			-- Base configuration using the 'telescope' preset
			"telescope",
			winopts = {
				height = 0.85,
				width = 0.80,
				preview = {
					layout = "vertical",
					vertical = "down:60%", -- Preview window below
				},
			},
			keymap = {
				builtin = {
					["<C-d>"] = "preview-page-down",
					["<C-u>"] = "preview-page-up",
				},
			},
			fzf_opts = {
				-- Additional FZF options
				["--layout"] = "reverse",
			},
		})

		-- File navigation
		vim.keymap.set("n", "<leader>fe", function()
			-- Use git_files with fallback to regular files if not in git repo
			fzf.git_files({
				cwd = vim.fn.getcwd(),
				cmd = "git ls-files --exclude-standard --cached --others",
				fail = function()
					fzf.files()
				end,
			})
		end, { desc = "Find files (git with fallback)" })

		-- Buffer, oldfiles and marks navigation
		vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
		vim.keymap.set("n", "<leader>fh", fzf.oldfiles, { desc = "Find history/oldfiles" })
		vim.keymap.set("n", "<leader>fm", fzf.marks, { desc = "Find marks" })

		-- Search functionality
		vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Find by grep" })
		vim.keymap.set("n", "<leader>fw", function()
			fzf.grep_cword({ search = vim.fn.expand("<cword>") })
		end, { desc = "Find word under cursor" })

		-- LSP integration
		vim.keymap.set("n", "<leader>fr", fzf.lsp_references, { desc = "Find references" })
		vim.keymap.set("n", "<leader>fd", fzf.lsp_definitions, { desc = "Find definitions" })
		vim.keymap.set("n", "<leader>ft", fzf.lsp_typedefs, { desc = "Find type definitions" })
		vim.keymap.set("n", "<leader>fi", fzf.lsp_implementations, { desc = "Find implementations" })

		-- Document symbols and diagnostics
		vim.keymap.set("n", "<leader>ff", fzf.lsp_document_symbols, { desc = "Find document symbols" })
		vim.keymap.set("n", "<leader>fS", fzf.lsp_workspace_symbols, { desc = "Find workspace symbols" })
		vim.keymap.set("n", "<leader>fx", fzf.diagnostics_document, { desc = "Find document diagnostics" })
		vim.keymap.set("n", "<leader>fX", fzf.diagnostics_workspace, { desc = "Find workspace diagnostics" })

		-- Additional useful commands
		vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "Find keymaps" })
		vim.keymap.set("n", "<leader>fc", fzf.command_history, { desc = "Find command history" })
		vim.keymap.set("n", "<leader>f/", fzf.grep_curbuf, { desc = "Find in current buffer" })

		-- Git integration
		vim.keymap.set("n", "<leader>fgc", fzf.git_commits, { desc = "Find git commits" })
		vim.keymap.set("n", "<leader>fgb", fzf.git_branches, { desc = "Find git branches" })
		vim.keymap.set("n", "<leader>fgs", fzf.git_status, { desc = "Find git status" })

		-- Register bindings with which-key
		-- local wk = require("which-key")
		-- wk.add({
		-- 	["<leader>f"] = {
		-- 		name = "[F]ind",
		-- 		e = "Files (git with fallback)",
		-- 		b = "Buffers",
		-- 		h = "History/oldfiles",
		-- 		m = "Marks",
		-- 		g = "Grep (live)",
		-- 		w = "Word under cursor",
		-- 		r = "References",
		-- 		d = "Definitions",
		-- 		t = "Type definitions",
		-- 		i = "Implementations",
		-- 		s = "Document symbols",
		-- 		S = "Workspace symbols",
		-- 		x = "Document diagnostics",
		-- 		X = "Workspace diagnostics",
		-- 		k = "Keymaps",
		-- 		c = "Command history",
		-- 		["/"] = "Current buffer",
		-- 		g = {
		-- 			name = "[G]it",
		-- 			c = "Commits",
		-- 			b = "Branches",
		-- 			s = "Status",
		-- 		},
		-- 	},
		-- })
	end,
}
