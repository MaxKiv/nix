{ pkgs, inputs, ... }:

let
  dotfiles = inputs.dotfiles;
in
{
  xdg.configFile = {
    "nvim/init.lua" = { source = ../../dotfiles/nvim/init.lua; };
    "nvim/lazy-lock.json" = { source = ../../dotfiles/nvim/lazy-lock.json; };
    "nvim/.stylua.toml" = { source = ../../dotfiles/nvim/.stylua.toml; };
    "nvim/lua" = { source = ../../dotfiles/nvim/lua; };
    "nvim/spell" = { source = ../../dotfiles/nvim/spell; };
  };

  home.packages = with pkgs; [ neovim ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
    vimdiff = "nvim -d";
  };
}
