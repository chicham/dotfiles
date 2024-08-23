return {
	"chrisgrieser/nvim-spider",

	-- Directly configure within the plugin table using `config`
	opts = {
		skipInsignificantPunctuation = true,
	},
	-- Define key mappings
	keys = {
		{
			"w",
			"<cmd>lua require('spider').motion('w')<CR>",
			mode = { "n", "o", "x" },
			desc = "Spider forward to word",
		},
		{
			"e",
			"<cmd>lua require('spider').motion('e')<CR>",
			mode = { "n", "o", "x" },
			desc = "Spider forward to end of word",
		},
		{
			"b",
			"<cmd>lua require('spider').motion('b')<CR>",
			mode = { "n", "o", "x" },
			desc = "Spider backward to word",
		},
		{
			"ge",
			"<cmd>lua require('spider').motion('ge')<CR>",
			mode = { "n", "o", "x" },
			desc = "Spider backward to end of word",
		},
	},
}
