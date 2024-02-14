return {
  -- A task runner and job management plugin for Neovim
  {
    'stevearc/overseer.nvim',
    opts = {},
    config = function()
      require('overseer').setup({
        templates = { "builtin", "user.c_build" },
      })
    end,
  }
}
