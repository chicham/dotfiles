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
				fullscreen = true,        -- Start fullscreen
				preview = {
					layout = "vertical",  -- Stack preview above suggestions
					vertical = "up:75%",  -- Preview takes 75% of the window height
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

		-- LSP integration - override standard LSP keymaps
		vim.keymap.set("n", "gd", fzf.lsp_definitions, { desc = "Go to definitions" })
		vim.keymap.set("n", "gr", fzf.lsp_references, { desc = "Go to references" })
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
		vim.keymap.set("n", "<leader>fz", fzf.grep_curbuf, { desc = "Fuzzy search current buffer" })
		vim.keymap.set("n", "<leader>fj", fzf.jumps, { desc = "Find jumps" })
		vim.keymap.set("n", "<leader>fl", fzf.lines, { desc = "Find lines in loaded buffers" })
		vim.keymap.set("n", "<leader>fM", fzf.manpages, { desc = "Find man pages" })

		-- Git integration
		vim.keymap.set("n", "<leader>fgc", fzf.git_commits, { desc = "Find git commits" })
		vim.keymap.set("n", "<leader>fgb", fzf.git_branches, { desc = "Find git branches" })
		vim.keymap.set("n", "<leader>fgs", fzf.git_status, { desc = "Find git status" })

		-- TODO/XXX/FIXME/BUG search functionality (replacing trouble.nvim)
		vim.keymap.set("n", "<leader>tt", function()
			fzf.grep({
				search = "TODO|XXX|FIXME|BUG",
				rg_opts = "--type-not=binary --no-heading --color=always --smart-case --regexp",
				fzf_opts = { ["--delimiter"] = ":", ["--preview-window"] = "up:60%" },
			})
		end, { desc = "Find TODOs/FIXMEs in current buffer" })

		vim.keymap.set("n", "<leader>tT", function()
			fzf.live_grep({
				search = "TODO|XXX|FIXME|BUG",
				rg_opts = "--type-not=binary --no-heading --color=always --smart-case --regexp",
				fzf_opts = { ["--delimiter"] = ":", ["--preview-window"] = "up:60%" },
			})
		end, { desc = "Find TODOs/FIXMEs in project" })

		-- Trouble.nvim replacement keybindings
		vim.keymap.set("n", "<leader>tD", fzf.diagnostics_workspace, { desc = "Workspace Diagnostics (fzf)" })
		vim.keymap.set("n", "<leader>td", fzf.diagnostics_document, { desc = "Buffer Diagnostics (fzf)" })

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
