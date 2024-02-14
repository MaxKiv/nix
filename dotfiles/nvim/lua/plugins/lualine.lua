return {
  {

    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local navic = require "nvim-navic"

      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          -- theme = "solarized",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {},
          always_divide_middle = true,
        },
        sections = {
          lualine_a = {
            function ()
              return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            end
          },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            { "filename" },
            {
              function()
                return navic.get_location()
              end,
              cond = function()
                return navic.is_available()
              end,
              color = { fg = "ffaf00ff" },
            },
          },
          lualine_x = { "filetype", "fileformat" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = {},
      })
    end
  },
}
