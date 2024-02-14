return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = nil, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects"
    },

    opts = {
      -- A list of parser names, or "all"
      ensure_installed = {
        "c",
        "cpp",
        "rust",
        "python",
      },

      -- Install languages synchronously (only applied to `ensure_installed`)
      sync_install = true,

      -- Automatically install missing parsers when entering buffer
      auto_install = false,

      -- Highlight using treesitters abstract syntax tree
      highlight = { enable = true, },

      -- Use treesitter to find correct indentation levels
      indent = { enable = true, },

      -- Enable incremental selection
      incremental_selection = {
        -- enable = false,
        -- keymaps = {
        --   init_selection = "<C-Space>",
        --   node_incremental = "<C-Space>",
        --   scope_incremental = "<nop>",
        --   node_decremental = "<bs>",
        -- }
      },

      -- Treesitter text objects 🙌
      textobjects = {
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            -- ["ix"] = "@statement.inner",
          },
        },

        swap = {
          enable = true,
          swap_next = {
            ["cxn"] = "@parameter.inner",
          },
          swap_previous = {
            ["cxp"] = "@parameter.inner",
          },
        },

        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]a"] = "@parameter.outer",
            ["]m"] = "@function.outer",
            ["]]"] = { query = "@class.outer", desc = "Next class start" },
            --
            -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
            ["]o"] = "@loop.*",
            -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
            --
            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[a"] = "@parameter.outer",
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
          -- Below will go to either the start or the end, whichever is closer.
          -- Use if you want more granular movements
          -- Make it even more gradual by adding multiple queries and regex.
          goto_next = {
            ["]i"] = "@conditional.outer",
          },
          goto_previous = {
            ["[i"] = "@conditional.outer",
          }
        },

      },

      playground = {
        enable = false,
        disable = {},
        updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
          toggle_query_editor = 'o',
          toggle_hl_groups = 'i',
          toggle_injected_languages = 't',
          toggle_anonymous_nodes = 'a',
          toggle_language_display = 'I',
          focus_language = 'f',
          unfocus_language = 'F',
          update = 'R',
          goto_node = '<cr>',
          show_help = '?',
        },
      }
    },

    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      -- robot parser
      -- NOTE: if this doesnt work, do not forget to copy the TS queries
      -- (highlights.scm et friends) to somewhere in the vim runtime
      -- path/queries (h: rtp) and maybe automate that next time :)
      local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
      parser_config.robot = {
        install_info = {
          url = "https://github.com/Hubro/tree-sitter-robot.git" , -- local path or git repo
          files = { "src/parser.c" },                       -- note that some parsers also require src/scanner.c or src/scanner.cc
          -- optional entries:
          -- branch = "main",                                  -- default branch in case of git repo if different from master
          generate_requires_npm = false,                    -- if stand-alone parser without npm dependencies
          requires_generate_from_grammar = false,           -- if folder contains pre-generated src/parser.c
        },
        filetype = "robot",                                 -- if filetype does not match the parser name
      }
    end,
  },
}
