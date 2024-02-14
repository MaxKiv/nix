return {
  {
    -- Better surround
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
        surrounds = {
          ["a"] = { "<", ">" },
        }
      })
    end

    -- old Surround
    --use { "tpope/vim-surround", }
  },
}
