{ pkgs, username, ... }:
{

  environment.systemPackages = with pkgs; [
    flashfocus # Python script that flashes window I switch focus to
  ];

  home-manager.users.${username} =
    { config
    , pkgs
    , ...
    }: {
      # Symlink the dotfile
      xdg.configFile = {
        "flashfocus/flashfocus.yml" = { source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/flashfocus/flashfocus.yml"; };
      };
    };
}
