return {
	"chipsenkbeil/org-roam.nvim",
	tag = "0.1.1",
	-- Load after orgmode
	dependencies = {
		{
			"nvim-orgmode/orgmode",
			tag = "0.3.7",
		},
	},
	config = function()
		require("org-roam").setup({
			-- Key bindings
			bindings = {
				prefix = "<Leader>r",
				capture = "<Leader>rc",           -- (c)apture
				complete_at_point = "<Leader>r.",
				find_node = "<Leader>rf",         -- (f)ind node
				insert_node = "<Leader>ri",       -- (i)nsert node
				insert_node_immediate = "<Leader>rI", -- (I)mmediate insert
				quickfix_backlinks = "<Leader>rb", -- (b)acklinks
				toggle_roam_buffer = "<Leader>rt", -- (t)oggle buffer
			},

			-- Main directory for knowledge base
			directory = "~/.orgfiles/orgroam/",

			-- Additional org files to include in the knowledge base
			org_files = {
				"~/.orgfiles/research/",
			},

			-- Database settings for knowledge graph
			database = {
				persist = true,
				update_on_save = true
			},

			-- Default templates for nodes
			templates = {
				p = {
					description = "paper",
					template = "* ${title}\n:PROPERTIES:\n:AUTHOR: %?\n:YEAR: \n:DOI: \n:CITE_KEY: \n:ID: %(org-id-uuid)\n:END:\n\n",
					target = "%[slug].org",
				},
				c = {
					description = "concept",
					template = "* ${title}\n:PROPERTIES:\n:ID: %(org-id-uuid)\n:END:\n\n%?",
					target = "%[slug].org",
				},
			},

			-- Settings for immediate insertion
			immediate = {
				template = "* ${title}\n:PROPERTIES:\n:ID: %(org-id-uuid)\n:END:\n\n%?",
				target = "%[slug].org",
			},

			-- Extensions for research workflow
			extensions = {
				-- Daily research journals
				dailies = {
					directory = "journal",
					templates = {
						d = {
							description = "default",
							template = "* %<%Y-%m-%d %a>\n\n** Research activities\n%?\n\n** Insights\n\n** References\n\n** Next steps\n",
							target = "%<%Y-%m-%d>.org",
						},
					},
					bindings = {
						capture_today = "<Leader>rdc", -- (d)aily (c)apture
						find_date = "<Leader>rdf",    -- (d)aily (f)ind
						goto_today = "<Leader>rdt",   -- (d)aily (t)oday
					},
				},
			},
		})
	end,
}
