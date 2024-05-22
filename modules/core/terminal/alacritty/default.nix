{ config, pkgs, home-manager, lib, alacritty-catppuccin, username, ... }:

{
  home-manager.users.${username} = { config, pkgs, ... }:
    {
      home.packages = with pkgs; [ alacritty ];

      programs.alacritty.enable = true;

      xdg.configFile = {
        "alacritty/alacritty.toml" = {
          source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/git/nix/dotfiles/.config/alacritty/alacritty.toml";
        };

        "alacritty/catppuccin-mocha.toml" = {
          source = "${alacritty-catppuccin}/catppuccin-mocha.toml";
        };
      };
    };
}

