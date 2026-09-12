-- jj.nvim: drives Jujutsu from nvim -- log browsing on a live-editable revset,
-- revision and range diffs, a status picker, conflict resolution.
--
-- `:JjReview` builds a review surface on top of it: a file picker over what a
-- chain changed, and for each file a side-by-side diff of the working copy
-- against the chain's base. The working-copy side stays a real file buffer at
-- its real path, which is what makes it commentable -- quickfix-review anchors
-- comments to a buffer number and exports them as `path:line`, so a comment
-- placed in a synthetic buffer exports to a reference nothing can resolve.
--
-- Two surfaces are deliberately not used for this:
--
--   * jj.nvim's `diffview`/`codediff` backends render both sides into scratch
--     buffers, so neither side is commentable.
--   * vcsigns' own `diffview` (`<leader>hd`) keeps the real buffer, but drives
--     its file list through the quickfix list, which is where quickfix-review
--     keeps comments; opening it replaces them. It also builds that list from
--     the commit-offset base, ignoring a revset set via `target_revset`, so
--     under a chain base the list and the diffs would disagree.
--
-- The `native` backend has neither problem: it splits the revision in beside
-- the current buffer and leaves the quickfix list alone.
return {
	"NicolasGB/jj.nvim",
	version = "*",
	dependencies = { "algmyr/vcsigns.nvim", "ibhagwan/fzf-lua" },
	cmd = { "J", "Jdiff", "Jvdiff", "Jhdiff", "Jbrowse", "Jread", "Jedit", "JjReview" },
	config = function()
		require("jj").setup({})

		local vcsigns = require("vcsigns.actions")

		-- Run jj in `root` without a shell, and from the workspace root rather
		-- than the editor's cwd, which drifts.
		---@param root string Directory containing `.jj`.
		---@param args string[] Arguments after `jj -R <root> --no-pager`.
		---@return string|nil stdout, string|nil err
		local function jj(root, args)
			local argv = { "jj", "-R", root, "--no-pager" }
			vim.list_extend(argv, args)
			local res = vim.system(argv, { text = true }):wait()
			if res.code ~= 0 then
				return nil, vim.trim(res.stderr)
			end
			return res.stdout, nil
		end

		-- Open `path` beside the same file as of `base`, with the editable side
		-- carrying the real file. vcsigns is pointed at the same base so its
		-- signs and ]h / [h describe the chain rather than the current change.
		---@param root string
		---@param base string Commit id to diff against.
		---@param path string Absolute path to the file.
		local function review_file(root, base, path)
			vim.cmd.edit(vim.fn.fnameescape(path))
			local bufnr = vim.api.nvim_get_current_buf()
			vcsigns.start_if_needed(bufnr)
			if require("vcsigns.state").get(bufnr).vcs.vcs ~= nil then
				vcsigns.target_revset(bufnr, base)
			end

			-- A file the chain adds has no content at the base, and asking jj
			-- for it is an error rather than an empty side. There is nothing to
			-- put opposite it, so leave the single window: with the base already
			-- set, vcsigns marks the whole file as added, which is the diff.
			local at_base = jj(root, { "file", "list", "-r", base, path })
			if not at_base or vim.trim(at_base) == "" then
				vim.notify(
					vim.fn.fnamemodify(path, ":.") .. " is added by this chain",
					vim.log.levels.INFO
				)
				return
			end

			require("jj.diff").diff_current({ rev = base, path = path, backend = "native" })
		end

		-- Files a revset's chain changed, as absolute paths. `jj diff --summary`
		-- prints a status column and paths relative to the invocation directory,
		-- which is `root` here.
		---@param root string
		---@param base string
		---@return string[]|nil files, string|nil err
		local function changed_files(root, base)
			local out, err = jj(root, { "diff", "--summary", "--from", base, "--to", "@" })
			if err then
				return nil, err
			end
			local files = {}
			for line in out:gmatch("[^\n]+") do
				local path = line:match("^%a%s+(.+)$")
				if path then
					files[#files + 1] = root .. "/" .. path
				end
			end
			return files, nil
		end

		-- Complete the first argument as a revset and the rest as paths. The
		-- revset candidates come from the repo itself -- its bookmarks and the
		-- revset aliases defined in jj's config -- so the names offered are the
		-- ones this repo actually understands rather than a hardcoded list.
		--
		-- Neovim exposes this through `getcompletion()`, which is what blink's
		-- cmdline source reads, so the popup fills in with no further wiring.
		---@param arglead string
		---@param cmdline string
		---@return string[]
		local function complete(arglead, cmdline)
			-- `:JjReview` itself is the first word; a trailing space means the
			-- next argument has been started but is still empty.
			local words = vim.split(vim.trim(cmdline), "%s+")
			local position = #words - 1 + (cmdline:match("%s$") and 1 or 0)

			if position > 1 then
				return vim.fn.getcompletion(arglead, "file")
			end

			local root = vim.fs.root(0, { ".jj" })
			if not root then
				return {}
			end

			-- A revset alias is listed once per arity, and a bookmark can repeat
			-- across remotes, so collect through a set before filtering.
			local seen, candidates = {}, {}
			local function offer(candidate)
				if candidate ~= "" and not seen[candidate] then
					seen[candidate] = true
					candidates[#candidates + 1] = candidate
				end
			end

			for _, builtin in ipairs({ "@", "chain(@)", "mine()", "pending()", "main::@" }) do
				offer(builtin)
			end
			local bookmarks = jj(root, { "bookmark", "list", "-T", 'name ++ "\n"' })
			for name in (bookmarks or ""):gmatch("[^\n]+") do
				offer(name)
			end
			local aliases = jj(root, { "config", "list", "--include-defaults", "revset-aliases" })
			for name in (aliases or ""):gmatch('revset%-aliases%.[\"\']?([%w_]+)') do
				offer(name .. "()")
			end

			return vim.tbl_filter(function(candidate)
				return candidate:sub(1, #arglead) == arglead
			end, candidates)
		end

		-- Review a jj chain: pick among the files it changed, and diff each one
		-- against the commit the chain starts from.
		--
		-- Trailing paths skip the picker and open exactly those files -- the
		-- "review only these" case, where a picker offers a step rather than a
		-- choice. They may be relative to the cwd or absolute.
		--
		-- The diff base set here is repo-wide and outlives the diff windows;
		-- `<leader>hB` with an empty revset restores the default base.
		vim.api.nvim_create_user_command("JjReview", function(cmd)
			local root = vim.fs.root(0, { ".jj" })
			if not root then
				vim.notify("JjReview: no jj workspace above this buffer", vim.log.levels.ERROR)
				return
			end

			local revset = cmd.fargs[1] or "chain(@)"
			local paths = vim.list_slice(cmd.fargs, 2)

			-- Resolving the base is also the snapshot: any jj invocation commits
			-- the working copy first, so `@` is current before the diff is taken.
			local base, err = jj(root, {
				"log", "-r", "roots(" .. revset .. ")-", "--no-graph", "-T", "commit_id",
			})
			if err then
				vim.notify("JjReview: " .. err, vim.log.levels.ERROR)
				return
			end
			base = vim.trim(base)
			if base == "" then
				vim.notify("JjReview: no chain above " .. revset, vim.log.levels.ERROR)
				return
			end

			if #paths > 0 then
				for _, path in ipairs(paths) do
					review_file(root, base, vim.fn.fnamemodify(path, ":p"))
				end
				return
			end

			local files, files_err = changed_files(root, base)
			if files_err then
				vim.notify("JjReview: " .. files_err, vim.log.levels.ERROR)
				return
			end
			if #files == 0 then
				vim.notify("JjReview: " .. revset .. " changed nothing", vim.log.levels.WARN)
				return
			end

			-- Entries are displayed relative to the cwd but previewed through an
			-- absolute path, since the preview command inherits fzf's working
			-- directory rather than the editor's.
			require("fzf-lua").fzf_exec(vim.tbl_map(function(p)
				return vim.fn.fnamemodify(p, ":.")
			end, files), {
				prompt = "Review " .. base:sub(1, 8) .. "..@> ",
				preview = table.concat({
					"jj", "-R", vim.fn.shellescape(root), "--no-pager", "diff",
					"--color=always", "--git",
					"--from", vim.fn.shellescape(base), "--to", "@",
					"--", vim.fn.shellescape(root) .. "/{}",
				}, " "),
				actions = {
					["default"] = function(selected)
						for _, rel in ipairs(selected) do
							review_file(root, base, vim.fn.fnamemodify(rel, ":p"))
						end
					end,
				},
			})
		end, {
			nargs = "*",
			complete = complete,
			desc = "Review a jj chain against its base, file by file",
		})
	end,
}
