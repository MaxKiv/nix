{ username, ... }: {
  home-manager.users.${username} =
    { config
    , pkgs
    , ...
    }: {
      programs.yazi.enable = true;
      stylix.targets.yazi.enable = true;
    };
}
