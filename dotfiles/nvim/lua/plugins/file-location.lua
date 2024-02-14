return {
  {
    -- Get full file path
    "diegoulloao/nvim-file-location",
    config = function()
      require("nvim-file-location").setup({
        -- keymap = "<leader>L",
        -- mode = "workdir", -- options: workdir | absolute
        -- add_line = true,
        -- add_column = false,
      })
    end
  },
}
