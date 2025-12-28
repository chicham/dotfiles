local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"eapp",
		fmt(
			[[
import dataclasses

from absl import app, flags, logging
from etils import eapp, epath

@dataclasses.dataclass
class {}:
    pass

def main(cfg: {}):
    pass

if __name__ == "__main__":
    app.run(main, flags_parser=eapp.make_flags_parser({}))
]],
			{
				i(1, "AppConfig"),
				rep(1),
				rep(1),
			}
		)
	),
}
