{
  pkgs,
  username,
  lib,
  ...
}: {
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  systemd.services.greetd.environment = {
    RUST_BACKTRACE = "1";
    RUST_LOG = "greetd=debug";
  };

  # use greetd with tuigreet as login manager
  services.greetd = {
    enable = true;
    # vt = 2;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --debug \
            --asterisks \
            --user-menu \
            --remember \
            --cmd sway
        '';
        # command = "${pkgs.greetd.tuigreet}/bin/wlgreet --command sway";
        user = "${username}";
        initial_session.user = lib.mkForce "${username}";
        default_session.user = lib.mkForce "${username}";
      };
    };
  };

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
  };
}
