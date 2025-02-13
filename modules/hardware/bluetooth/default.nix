{username, ...}: {
  # Enable bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller on boot

  # TODO: remove this when fix is upstreamed
  # Fix Unit tray.target not found
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };
  };
}
