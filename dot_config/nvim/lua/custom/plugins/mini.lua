-- The mini.nvim modules this config uses, one lazy.nvim spec each.
--
-- mini ships every module both as part of the `mini.nvim` monorepo and as its
-- own repository. This file takes the per-module repositories and groups their
-- specs here rather than depending on the monorepo: a lazy.nvim spec has a
-- single load point, so one monorepo spec would collapse every module below
-- onto one trigger. Kept separate, `mini.surround` still loads on `ys`/`ds`/`cs`
-- and `mini.indentscope` still loads on reading a file, while the config only
-- carries one file for the lot.
--
-- Which of the two collections a module comes from is decided by:
--   mini first; snacks only for what mini lacks and that earns its place on
--   evidence; never a module of either that duplicates an installed plugin.
-- That rules out mini.pick, mini.files, mini.statusline and mini.diff, which
-- fzf-lua, oil, lualine+navic and vcsigns already cover.

return {
  -- Surround (replaces machakann/vim-sandwich), configured to mirror
  -- tpope/vim-surround's mappings (operator-key prefixes, no s-prefix):
  --   ds<pair>        delete surrounding    -- ds)  ds"  ds}  ds`
  --   cs<old><new>    change surrounding    -- cs)] turns (..) into [..]
  --   ys<motion><p>   add surrounding       -- ysiw"  surround word with "
  --   yss<pair>       add around the line   -- yss)
  --   S<pair>         add around selection  -- visual mode
  -- The `s` key stays free for leap/substitute; surround hangs off d/c/y.
  {
    "nvim-mini/mini.surround",
    version = false,
    keys = {
      { "ys", mode = "n", desc = "Add surround" },
      { "ds", mode = "n", desc = "Delete surround" },
      { "cs", mode = "n", desc = "Change surround" },
      { "S", mode = "x", desc = "Add surround (visual)" },
    },
    opts = {
      -- Search not only the covering pair but also the nearest one around.
      search_method = "cover_or_next",
      -- Built-in aliases already cover a whole category with one key:
      --   b = any bracket  () [] {}      (dsb / csb<new>)
      --   q = any quote    ' " `         (dsq / csq<new>)
      -- `a` ("any") below goes further: one key for brackets AND quotes
      -- together, so dsa deletes whatever pair is nearest without naming its
      -- type, and csa<new> changes it. Output defaults to () for when `a` is
      -- the *target*.
      custom_surroundings = {
        ["a"] = {
          input = { { "%b()", "%b[]", "%b{}", "'.-'", '".-"', "`.-`" }, "^.().*().$" },
          output = { left = "(", right = ")" },
        },
      },
      -- vim-surround layout. Unused features get an empty string to leave
      -- their default s-prefixed keys unmapped.
      mappings = {
        add = "ys",
        delete = "ds",
        replace = "cs",
        find = "",
        find_left = "",
        highlight = "",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
      },
    },
    config = function(_, opts)
      require("mini.surround").setup(opts)

      -- mini maps `ys` in Visual mode too; vim-surround uses `S` there instead.
      pcall(vim.keymap.del, "x", "ys")
      vim.keymap.set(
        "x",
        "S",
        [[:<C-u>lua MiniSurround.add('visual')<CR>]],
        { silent = true, desc = "Add surround (visual)" }
      )

      -- `yss<pair>` surrounds the whole line, like vim-surround (`_` is the
      -- linewise textobject); remap so it routes through the `ys` operator.
      vim.keymap.set("n", "yss", "ys_", { remap = true, desc = "Add surround around line" })
    end,
  },

  -- Operators (replaces tommcdo/vim-exchange).
  -- Exchange, replace, sort, evaluate, multiply as operators + line + visual.
  {
    "nvim-mini/mini.operators",
    version = false,
    keys = {
      -- exchange: cx{motion} / cxx (line) / cx (visual) -- matches vim-exchange
      { "cx", mode = { "n", "x" }, desc = "Exchange (operator)" },
      { "gR", mode = { "n", "x" }, desc = "Replace with register (operator)" },
      { "gs", mode = { "n", "x" }, desc = "Sort (operator)" },
      { "g=", mode = { "n", "x" }, desc = "Evaluate (operator)" },
    },
    opts = {
      evaluate = { prefix = "g=" },
      -- exchange on cx (not gx) so Neovim's built-in gx (open URL/file) is kept.
      exchange = { prefix = "cx" },
      -- multiply disabled: its default 'gm' collides with marks.nvim's preview
      -- mapping. Re-enable on a free key if wanted (e.g. prefix = 'gM').
      multiply = { prefix = "" },
      -- replace on gR (not gr) to avoid Neovim's built-in LSP grr/gra/grn/gri.
      replace = { prefix = "gR" },
      sort = { prefix = "gs" },
    },
  },

  -- Current-indent-scope visualizer + matching text objects. Replaces
  -- indent-blankline's `scope` highlight: ibl's scope is treesitter-based and
  -- coarse (in Python it highlights the whole enclosing function), whereas
  -- mini.indentscope's scope is indentation-based and fine (the actual current
  -- indent block) -- and it ships text objects computed from the *same* scope
  -- it draws, so "what you see highlighted" == "what ii/ai selects".
  --
  -- ii = inner scope (body lines), ai = scope + its border (the header line,
  -- e.g. the `def`/`if` line). [i/]i are intentionally NOT mapped here -- those
  -- stay on the @conditional treesitter moves defined in treesitter.lua.
  --
  -- The scope line is recoloured per indentation depth to mimic rainbow-
  -- delimiters (the look ibl gave via scope_highlight_from_extmark). Note this
  -- keys off indentation depth, not the actual bracket extmark, so the colour
  -- at a given line may differ from what ibl showed for bracketed code.
  {
    "nvim-mini/mini.indentscope",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local mi = require("mini.indentscope")

      mi.setup({
        symbol = "┊", -- same glyph as the ibl indent guides
        -- Static (no growth animation), to match ibl's scope cue.
        draw = {
          animation = function()
            return 0
          end,
        },
        options = { try_as_border = true },
        mappings = {
          object_scope = "ii",
          object_scope_with_border = "ai",
          -- Disabled: keep [i/]i bound to the @conditional moves
          -- (treesitter.lua).
          goto_top = "",
          goto_bottom = "",
        },
      })

      -- Rainbow-by-depth: relink the scope symbol's highlight to a
      -- RainbowDelimiter* group based on the current scope's indentation depth.
      -- Extmarks resolve their highlight by name at redraw, so updating the
      -- link recolours the already-drawn line.
      local rainbow = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      }
      local function update_hl()
        local ok, scope = pcall(mi.get_scope)
        if not ok or not scope or not scope.body then
          return
        end
        local sw = vim.fn.shiftwidth()
        if sw < 1 then
          sw = 1
        end
        local level = math.floor((scope.body.indent or 0) / sw)
        local idx = ((math.max(level, 1) - 1) % #rainbow) + 1
        vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = rainbow[idx] })
      end

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinEnter" }, {
        group = vim.api.nvim_create_augroup("MiniIndentscopeRainbow", { clear = true }),
        callback = vim.schedule_wrap(update_hl),
      })
    end,
  },

  -- Trailing-whitespace highlight (replaces ntpeters/vim-better-whitespace).
  -- Highlight only: nothing strips on save, and trimming is explicit via
  -- MiniTrailspace.trim(). Unlike better-whitespace it also stops highlighting
  -- in Insert mode and in the window you have left, so the marks only show
  -- where you are not currently typing.
  {
    "nvim-mini/mini.trailspace",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Split/join argument lists (replaces Wansmer/treesj), on gJ.
  --
  -- The hooks below are what make the output match the surrounding style, and
  -- they are language-aware because the conventions are. Splitting adds a
  -- trailing separator inside braces only; joining removes it from every
  -- bracket type, since a hand-written `f(x, y,)` should join to `f(x, y)`.
  -- Padding the braces to `{ a = 1 }` is a Lua convention -- Python writes
  -- `{"a": 1}` -- so it is applied per filetype rather than globally.
  {
    "nvim-mini/mini.splitjoin",
    version = false,
    keys = {
      {
        "gJ",
        function()
          require("mini.splitjoin").toggle()
        end,
        desc = "Split/Join Block",
      },
    },
    config = function()
      local sj = require("mini.splitjoin")
      local gen = sj.gen_hook
      local curly = { brackets = { "%b{}" } }
      local all = { brackets = { "%b()", "%b[]", "%b{}" } }

      local pad_curly = gen.pad_brackets(curly)
      local function pad_if_lua(positions)
        if vim.bo.filetype ~= "lua" then
          return positions
        end
        return pad_curly(positions)
      end

      sj.setup({
        -- gJ above is the only entry point; leave mini's own keys unmapped.
        mappings = { toggle = "", split = "", join = "" },
        split = { hooks_post = { gen.add_trailing_separator(curly) } },
        join = { hooks_post = { gen.del_trailing_separator(all), pad_if_lua } },
      })
    end,
  },

  -- File/filetype icons (replaces nvim-tree/nvim-web-devicons). oil, fzf-lua
  -- and octo ask for the devicons module by name, so mock_nvim_web_devicons()
  -- registers a shim under that name backed by MiniIcons; all fourteen
  -- functions those plugins reach for resolve through it.
  --
  -- Icon highlight groups are colour-named (MiniIconsGreen, ...) rather than
  -- type-named (DevIconLua, ...). Nothing in this config references a DevIcon*
  -- group, so the rename is invisible here -- but a colorscheme override that
  -- targeted one would need updating.
  {
    "nvim-mini/mini.icons",
    version = false,
    lazy = true,
    opts = {},
    init = function()
      -- The shim has to exist before any consumer requires "nvim-web-devicons",
      -- and requiring it is itself what loads this spec.
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- Keyword highlighting in comments (replaces folke/todo-comments.nvim), plus
  -- hex colour swatches.
  --
  -- The keyword list is the union of todo-comments' seven defaults and their
  -- thirteen aliases, because hipatterns has no built-in set -- every pattern here is
  -- one that used to be recognised. `%f[%w]...%f[%W]` are frontier patterns:
  -- they anchor the match to a word boundary so TODO matches in `TODO:` and
  -- `TODO(name):` but not inside `TODOS`.
  --
  -- Two differences from todo-comments are deliberate and accepted: only the
  -- keyword is coloured, not the text following it; and matching is not
  -- restricted to comments, so a keyword inside a string literal highlights
  -- too.
  {
    "nvim-mini/mini.hipatterns",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local hipatterns = require("mini.hipatterns")

      local function words(group, list)
        local out = {}
        for _, word in ipairs(list) do
          out[word] = { pattern = "%f[%w]()" .. word .. "()%f[%W]", group = group }
        end
        return out
      end

      local highlighters = vim.tbl_extend(
        "error",
        words("MiniHipatternsFixme", { "FIX", "FIXME", "BUG", "FIXIT", "ISSUE" }),
        words("MiniHipatternsHack", { "HACK" }),
        words("MiniHipatternsTodo", { "TODO" }),
        words("MiniHipatternsNote", {
          "NOTE",
          "INFO",
          "WARN",
          "WARNING",
          "XXX",
          "PERF",
          "OPTIM",
          "OPTIMIZE",
          "PERFORMANCE",
          "TEST",
          "TESTING",
          "PASSED",
          "FAILED",
        })
      )
      highlighters.hex_color = hipatterns.gen_highlighter.hex_color()

      hipatterns.setup({ highlighters = highlighters })
    end,
  },
}
