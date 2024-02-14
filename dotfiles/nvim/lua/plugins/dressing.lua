return {

  -- With the release of Neovim 0.6 we were given the start of extensible core
  -- UI hooks (vim.ui.select and vim.ui.input). They exist to allow plugin
  -- authors to override them with improvements upon the default behavior,
  -- so that's exactly what we're going to do.
  {
    'stevearc/dressing.nvim',
    opts = {},
  },
}
