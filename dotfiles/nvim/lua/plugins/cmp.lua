-- Completion
return {
  {
    "onsails/lspkind-nvim", -- better looking cmp window
  },
  { "hrsh7th/vim-vsnip" },
  { "hrsh7th/cmp-vsnip" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/cmp-path" },
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ["<C-j>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ['<C-e>'] = cmp.mapping.abort(),
        }),
        completion = {
          keyword_length = 2,
          completeopt = "menu,noselect",
        },
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
          }),
        },
        formatting = {
          format = lspkind.cmp_format {
            mode = "Symbol",
            maxwidth = 50,
            ellipsis_char = '...',
            menu = {
              nvim_lsp = "[LSP]",
              treesitter = "[Tree]",
              spell = "[Spell]",
              vsnip = "[Snip]",
              nvim_lua = "[Lua]",
              path = "[Path]",
              buffer = "[Buffer]",
            },
          },
        },
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "treesitter" },
            { name = "vsnip" }, -- For vsnip users.
            { name = "spell" },
            { name = "buffer" },
            { name = "path" }, },
          { { name = "buffer" }, }),

        experimental = {
          ghost_text = {
            hl_group = "Comment",
          },
        },
      })

      -- Set configuration for specific filetype.
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
          { name = 'buffer' },
        })
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      -- Avoid ex bang listing windows path in WSL
      cmp.setup.cmdline(':!', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'path' }
        },
        { name = 'cmdline', keyword_pattern = [=[[^[:blank:]\!]*]=], keyword_length = 4 }
      })
    end,
  },

}
