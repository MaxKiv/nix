# Kanshi is a daemon to hotswap monitors
{username, ...}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      kanshi
      wl-mirror
    ];

    xdg.configFile = {
      "kanshi/config" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/kanshi/config";};
    };
  };
}
