{
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.clipman];

    # https://github.com/nix-community/home-manager/blob/master/modules/services/clipman.nix
    systemd.user.services.clipman = {
      Unit = {
        Description = "Clipboard management daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store --max-items=200";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = "on-failure";
        KillMode = "mixed";
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
