{ config, pkgs, inputs, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dotfiles = inputs.dotfiles;
in
{
  xdg.configFile = {
    "nvim/init.lua" = { source = mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/nvim/init.lua"; };
    "nvim/lazy-lock.json" = { source = mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/nvim/lazy-lock.json"; };
    "nvim/.stylua.toml" = { source = mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/nvim/.stylua.toml"; };
    "nvim/lua" = { source = mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/nvim/lua"; };
    "nvim/spell" = { source = mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/nvim/spell"; };
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
