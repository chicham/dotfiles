-- Treesitter-based "any block" text object, mapped to ib / ab.
--
-- Selects the innermost node around the cursor that is delimited by either:
--   • any bracket pair:  ()  []  {}
--   • any string/quote, INCLUDING language-aware ones that pure lexical
--     matching gets wrong — Python's triple-quoted """ ... """ and f-strings
--     are a single `string` node to treesitter, so they are matched as one
--     unit (a `%b`/searchpair scan would see three separate `"` instead).
--
-- ib = inner (strips the delimiters), ab = around (keeps them). Both work in
-- operator-pending (dib) and visual (vib) modes, single- and multi-line.
--
-- Why a Lua walker instead of a treesitter-textobjects query: a query matches
-- by node *type*, so "any bracketed node" would mean enumerating every
-- bracketed type per language (tuple, list, dict, argument_list, …) and would
-- still miss some. The structural rule "first/last child are matching
-- delimiters" is type-agnostic and therefore more robust. It reuses the
-- already-attached `vim.treesitter` parser — no extra plugin.

local M = {}

local CLOSE = { ["("] = ")", ["["] = "]", ["{"] = "}" }

local function normal(s)
	vim.cmd.normal({ s, bang = true })
end

-- Is `node` a delimiter-bounded block we can select?
local function is_block(node, buf)
	-- String node (Python represents '', "", """ """ and f"" all as `string`
	-- with string_start / string_end delimiter children).
	if node:type() == "string" then
		return true
	end
	local cc = node:child_count()
	if cc < 2 then
		return false
	end
	local first, last = node:child(0), node:child(cc - 1)
	-- Generic string for grammars that expose string_start/string_end directly.
	if first:type() == "string_start" and last:type() == "string_end" then
		return true
	end
	-- Bracket pair, matched by delimiter text — language-agnostic.
	local ft = vim.treesitter.get_node_text(first, buf)
	local lt = vim.treesitter.get_node_text(last, buf)
	return CLOSE[ft] ~= nil and CLOSE[ft] == lt
end

-- Select a characterwise range from inclusive {row(1-indexed), col(0-indexed)}
-- positions. Returns false (selecting nothing) for a zero-width inner object
-- (e.g. ib on `()` or `""`) so the pending operator aborts cleanly instead of
-- mis-deleting an adjacent character.
local function set_selection(s, e)
	if s[1] > e[1] or (s[1] == e[1] and s[2] > e[2]) then
		return false
	end
	vim.api.nvim_win_set_cursor(0, s)
	local in_visual = vim.fn.mode():match("^[vV\22]") ~= nil
	normal(in_visual and "o" or "v")
	-- Clamp the end column so nvim_win_set_cursor never throws past EOL.
	local line_len = #vim.fn.getline(e[1])
	vim.api.nvim_win_set_cursor(0, { e[1], math.min(e[2], math.max(line_len - 1, 0)) })
	return true
end

---@param scope "i"|"a"
local function select_block(scope)
	local buf = 0
	local node = vim.treesitter.get_node()
	while node and not is_block(node, buf) do
		node = node:parent()
	end
	if not node then
		return
	end

	local sr, sc, er, ec
	if scope == "a" then
		sr, sc = node:start() -- inclusive start
		er, ec = node:end_() -- EXCLUSIVE end
	else
		local cc = node:child_count()
		sr, sc = node:child(0):end_() -- inner start = just after the open delimiter
		er, ec = node:child(cc - 1):start() -- inner end = start of the close delimiter (exclusive)
	end

	-- If the inner start lands past EOL (the open delimiter ended its line, as
	-- with a multi-line docstring), the content begins on the next line — don't
	-- let the cursor clamp back onto the delimiter.
	if sc >= #vim.fn.getline(sr + 1) then
		sr = sr + 1
		sc = 0
	end

	-- Convert the exclusive end column to an inclusive last-char column.
	if ec == 0 then
		er = er - 1
		ec = math.max(#vim.fn.getline(er + 1) - 1, 0)
	else
		ec = ec - 1
	end

	set_selection({ sr + 1, sc }, { er + 1, ec })
end

function M.setup()
	vim.keymap.set({ "x", "o" }, "ib", function()
		select_block("i")
	end, { desc = "inner block (any bracket / quote)", silent = true })
	vim.keymap.set({ "x", "o" }, "ab", function()
		select_block("a")
	end, { desc = "around block (any bracket / quote)", silent = true })
end

return M
