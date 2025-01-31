# Satty is a modern screenshot annotation tool
{username, ...}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [satty];

    xdg.configFile = {
      "satty/config.toml" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/satty/config.toml";};
    };
  };
}
