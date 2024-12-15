{
  config,
  pkgs,
  home-manager,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bat
  ];

  home-manager.users.${username} = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # Symlink the bat config files from my doftiles to the xdg config dir
    xdg.configFile = {
      "bat/bat.conf" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/bat/bat.conf";};
      "bat/themes" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/bat/themes";};
    };

    # Run bat cache --build after home-manager sets up the above symlinks
    home.activation.postActivate = ''
      ${pkgs.bat}/bin/bat cache --build
    '';

    home.sessionVariables = {
      BAT_CONFIG_PATH = "${config.home.homeDirectory}/git/nix/dotfiles/.config/bat/bat.conf";
    };
  };
}
