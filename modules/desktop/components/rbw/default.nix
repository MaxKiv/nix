{
  pkgs,
  lib,
  config,
  username,
  email,
  ...
}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    programs.rbw = {
      enable = true;
      settings = {
        email = email;
        lock_timeout = 300; # secs
        pinentry = pkgs.pinentry-curses;
      };
    };
  };
}
