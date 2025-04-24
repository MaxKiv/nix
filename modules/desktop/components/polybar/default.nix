{
  pkgs,
  lib,
  config,
  username,
  ...
}: {
  # symlink to sway config file in dotfiles repo
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    services.polybar = {
      enable = true;
      script = ''
        polybar &
      '';

      # package = pkgs.polybar.override {
      #   i3GapsSupport = true;
      #   alsaSupport = true;
      # };
    };

    xdg.configFile = {
      "polybar/config.ini" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/polybar/config.ini";
      };
      "polybar/idle-inhibitor.sh" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/polybar/idle-inhibitor.sh";
      };
      "polybar/mediaplayer.sh" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/polybar/mediaplayer.sh";
      };
      "polybar/power-profiles.sh" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/polybar/power-profiles.sh";
      };
      "polybar/powermenu.sh" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/polybar/powermenu.sh";
      };
      "polybar/toggle-idle-inhibitor.sh" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/polybar/toggle-idle-inhibitor.sh";
      };
    };
  };
}
