# Kanshi is a daemon to hotswap monitors, defaults to sway
{username, ...}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      # kanshi
      wl-mirror
    ];

    services.kanshi.enable = true;

    xdg.configFile = {
      "kanshi/config" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/kanshi/config";};
    };
  };
}
