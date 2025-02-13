# Swappy is a wayland screenshot annotation tool
{username, ...}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [swappy];

    xdg.configFile = {
      "swappy/config" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/swappy/config";};
    };
  };
}
