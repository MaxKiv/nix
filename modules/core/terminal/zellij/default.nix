{
  config,
  pkgs,
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    programs.zellij = {
      enable = true;
      enableBashIntegration = false; # Dont autostart in every terminal thanks
    };
    stylix.targets.zellij.enable = true;

    # symlink to zellij config file in dotfiles repo
    xdg.configFile = {
      "zellij/config.kdl" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/zellij/config.kdl";};
      "zellij/layouts" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/zellij/layouts";};
    };
  };
}
