{ pkgs, username, ... }:
{
  # Configures the wofi application launcher

  environment.systemPackages = with pkgs; [
    wofi-emoji # emoji picker for wofi
  ];

  home-manager.users.${username} =
    { config
    , pkgs
    , ...
    }: {
      stylix.targets.wofi.enable = true;
      programs.wofi.enable = true;

      xdg.configFile = {
        "wofi/config" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/wofi/config";
        };
      };
    };
}
