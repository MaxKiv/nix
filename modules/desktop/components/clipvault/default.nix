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
    home.packages = [pkgs.clipvault];

    # https://github.com/nix-community/home-manager/blob/master/modules/services/clipman.nix
    systemd.user.services.clipvault = {
      Unit = {
        Description = "Clipvaults clipboard management daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipvault}/bin/clipman store --min-entry-length 2 --max-entries 200 --max-entry-age 2d";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = "on-failure";
        KillMode = "mixed";
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
