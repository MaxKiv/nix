{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # waybar # Customisable wayland bar
    pavucontrol # Audio controller GUI
    # power-profiles-daemon # make power profiles available over D-Bus
    brightnessctl # CLI to control brightness
    networkmanager # The most popular way to manage wireless networks on Linux,
    networkmanagerapplet # Desktop environment-independent system tray GUI for networkmanager
    pulsemixer # CLI to control puleaudio
  ];

  # make power profiles available over D-Bus
  services.power-profiles-daemon.enable = true;

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    programs.waybar.enable = true;

    # Applets for nn and blueman
    services.network-manager-applet.enable = true;
    services.blueman-applet.enable = true;

    # We style waybar ourselves 💪
    stylix.targets.waybar.enable = false;

    # Automatically switch the power profile on plug and unplug if I'm using power-profiles-daemon
    systemd.user.services.auto-power-profile = {
      Install.WantedBy = ["default.target"];
      Service.ExecStart = let
        script = pkgs.writeShellApplication {
          name = "auto-power-profile";
          text = builtins.readFile ../../sway/scripts/auto-power-profile.sh;
          runtimeInputs = with pkgs; [
            inotify-tools
            power-profiles-daemon
            coreutils
          ];
        };
      in "${script}/bin/auto-power-profile";
    };

    xdg.configFile = {
      "waybar/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/waybar/config.jsonc";
      };
      "waybar/power_menu.xml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/waybar/power_menu.xml";
      };
      "waybar/style.css" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/waybar/style.css";
      };
    };
  };
}
