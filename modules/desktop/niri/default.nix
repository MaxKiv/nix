{
  pkgs,
  libs,
  inputs,
  username,
  ...
}: {
  # Import Compositor components
  imports = [
    ../components/waybar
    ../components/mako
    ../components/wofi
    ../components/clipman
    ../components/swappy
  ];

  environment.systemPackages = with pkgs; [
    swaylock-fancy # Fancy lock screen
    wev # wayland event viewer (find out key names)
    notify-desktop # provides the notify-send binary to trigger mako
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard-rs # wl-copy and wl-paste for copy/paste from stdin / stdout
    xclip # TODO: figure out why I still need this
    brightnessctl # CLI to control brightness
    pulsemixer # CLI to control puleaudio
    alsa-utils # for amixer to mute mic
    wdisplays # xrandr type gui to mess with monitor placement
  ];

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  # Niri.enable already enables this, but lets make it more clear
  services.gnome.gnome-keyring.enable = true;

  # Enable sway lockscreen utility to act as Pluggable Authentication Module, enabling it to unlock keyring
  security.pam.services.swaylock = {};

  services.libinput.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Automount sd cards
  services.udisks2.enable = true;

  # Set up upower to be able to get battery levels of connected devices.
  services.upower.enable = true;

  # Filesystem interface implemented by local/remote fileSystems: Mount, trash, and other functionalities for file explorer
  services.gvfs.enable = true;

  # network manager
  networking.networkmanager.enable = true;

  # bluetooth manager
  services.blueman.enable = true;
  services.dbus.packages = [pkgs.blueman];
  users.users.${username} = {
    extraGroups = ["bluetooth"];
  };

  # .desktop and XDG config files from HM get picked up
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.niri.homeModules.niri
    ];

    # Polkit: Toolkit for defining and handling the policy that allows unprivileged processes to speak to privileged processes
    services.polkit-gnome.enable = true; # polkit

    # idle management daemon
    services.swayidle.enable = true;

    programs.niri = {
      enable = true;
      settings = {
        outputs."eDP-1".scale = 1.0;
        environment."NIXOS_OZONE_WL" = "1";
      };
    };
  };
}
