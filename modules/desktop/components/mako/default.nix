{ pkgs, username, ... }: {

  # symlink to config file in dotfiles repo
  home-manager.users.${username} =
    { config
    , pkgs
    , ...
    }: {
      # A notification system developed by the swaywm maintainer
      services.mako.enable = true;
      stylix.targets.mako.enable = false;

      xdg.configFile = {
        "mako/config" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/mako/config";
        };
      };
    };
}
