return {

  {
    "eddyekofo94/gruvbox-flat.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- -- load the colorscheme here
      -- vim.g.gruvbox_flat_style = "dark"
      -- vim.cmd [[colorscheme gruvbox-flat]]
      --
      -- vim.cmd [[highlight Normal guibg=none]]
      -- vim.cmd [[highlight NonText guibg=none]]
    end,
  },

  -- tokyonight
  {
    "folke/tokyonight.nvim",
    event = "VeryLazy",
    opts = { style = "moon" },
  },

  -- catppuccin
  {
    "catppuccin/nvim",
    event = "VeryLazy",
    name = "catppuccin",
    config = function()
      vim.cmd.colorscheme "catppuccin-mocha"
    end
  },

}
