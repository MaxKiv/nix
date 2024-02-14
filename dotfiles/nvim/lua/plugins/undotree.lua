return {

  {
    "mbbill/undotree",
    keys = {
      "UndotreeHide",
      "UndotreeShow",
      "UndotreeFocus",
      "UndotreeToggle",
      "UpdateRemotePlugins",
      {
        "<leader>u",
        function() vim.cmd("UndotreeToggle") end,
        desc =
        "Show Undo Tree"
      },
    }
  },

}
