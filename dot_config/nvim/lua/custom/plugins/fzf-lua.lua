-- fzf-lua.lua
-- Fast and powerful fuzzy finder using FZF
return {
	"ibhagwan/fzf-lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- Optional for file icons
	},
	config = function()
		local fzf = require("fzf-lua")

		-- Setup fzf-lua with fullscreen layout
		fzf.setup({
			-- Base configuration using the 'ivy' preset for bottom layout
			"ivy",
			winopts = {
				fullscreen = true, -- Start fullscreen
				preview = {
					layout = "vertical", -- Stack preview above suggestions
					vertical = "up:75%", -- Preview takes 75% of the window height
				},
			},
			keymap = {
				builtin = {
					["<C-d>"] = "preview-page-down",
					["<C-u>"] = "preview-page-up",
				},
			},
			fzf_opts = {
				-- Additional FZF options for bottom layout
				["--layout"] = "reverse-list",
				["--info"] = "inline",
			},
		})

		-- g-mappings: Replace nvim goto commands with fzf (lowercase=document, uppercase=workspace)
		vim.keymap.set("n", "gd", fzf.lsp_definitions, { desc = "Go to definitions" })
		vim.keymap.set("n", "gr", fzf.lsp_references, { desc = "Go to references" })
		vim.keymap.set("n", "gD", fzf.lsp_declarations, { desc = "Go to declarations" })
		vim.keymap.set("n", "gi", fzf.lsp_implementations, { desc = "Go to implementations" })
		vim.keymap.set("n", "gt", fzf.lsp_typedefs, { desc = "Go to type definitions" })
		vim.keymap.set("n", "gb", fzf.buffers, { desc = "Go to buffer" })
		vim.keymap.set("n", "gq", fzf.lsp_document_symbols, { desc = "Go to symbol (document)" })
		vim.keymap.set("n", "gQ", fzf.lsp_workspace_symbols, { desc = "Go to symbol (workspace)" })

		-- <leader>f: All fzf operations
		-- Files & navigation
		vim.keymap.set("n", "<leader>ff", function()
			-- Use git_files with fallback to regular files if not in git repo
			fzf.git_files({
				cwd = vim.fn.getcwd(),
				cmd = "git ls-files --exclude-standard --cached --others",
				fail = function()
					fzf.files()
				end,
			})
		end, { desc = "Find files (git with fallback)" })
		vim.keymap.set("n", "<leader>fm", fzf.marks, { desc = "Find marks" })

		-- Search operations
		vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Find by grep (live)" })
		vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "Find word under cursor" })
		vim.keymap.set("n", "<leader>fv", fzf.grep_visual, { desc = "Find visual selection" })
		vim.keymap.set("n", "<leader>f/", fzf.grep_curbuf, { desc = "Find in current buffer" })
		vim.keymap.set("n", "<leader>ft", function()
			fzf.grep_curbuf({
				search = "TODO|XXX|FIXME|BUG",
				rg_opts = "--type-not=binary --no-heading --color=always --smart-case --regexp",
			})
		end, { desc = "Find TODOs/FIXMEs (current buffer)" })
		vim.keymap.set("n", "<leader>fT", function()
			fzf.live_grep({
				search = "TODO|XXX|FIXME|BUG",
				rg_opts = "--type-not=binary --no-heading --color=always --smart-case --regexp",
			})
		end, { desc = "Find TODOs/FIXMEs (workspace)" })

		-- LSP & diagnostics (lowercase=document, uppercase=workspace)
		vim.keymap.set("n", "<leader>fa", fzf.lsp_code_actions, { desc = "Find code actions" })
		vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document, { desc = "Find diagnostics (document)" })
		vim.keymap.set("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Find diagnostics (workspace)" })

		-- Git integration
		vim.keymap.set("n", "<leader>fc", fzf.git_commits, { desc = "Find git commits" })
		vim.keymap.set("n", "<leader>fB", fzf.git_branches, { desc = "Find git branches" })
		vim.keymap.set("n", "<leader>fG", fzf.git_status, { desc = "Find git status" })

		-- Utility
		vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Find help tags" })
		vim.keymap.set("n", "<leader>fC", fzf.command_history, { desc = "Find command history" })

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
