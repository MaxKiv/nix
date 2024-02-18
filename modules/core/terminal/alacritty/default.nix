{ config, pkgs, home-manager, username, ... }:

{
  home-manager.users.${username} = { config, pkgs, ... }:
  {
    home.packages = with pkgs; [ alacritty ];

    programs.alacritty.enable = true;

    xdg.configFile = {
      "alacritty/alacritty.yml" = {
        source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/git/nix/dotfiles/.config/alacritty/alacritty.yml";
      };
    };
  };
}

