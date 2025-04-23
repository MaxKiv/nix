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
