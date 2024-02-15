{ config, pkgs, inputs, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dotfiles = inputs.dotfiles;
in
{
  home.packages = with pkgs; [ alacritty ];

  programs.alacritty = {
    enable = true;
  };

  xdg.configFile = {
    "alacritty/alacritty.yml" = { 
      source = mkOutOfStoreSymlink
      "${config.home.homeDirectory}/git/nix/dotfiles/.config/alacritty/alacritty.yml";
    };
  };

}
