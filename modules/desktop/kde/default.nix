{ pkgs, ... }: {

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.xserver.desktopManager.plasma5.enable = true;
  # sddm is recommended for plasma5
  services.displayManager.sddm.enable = true;

  # KDE system packages
  environment.systemPackages = with pkgs; [
    #hicolor_icon_theme
    kleopatra
    kdeconnect
    spectacle
    gwenview
    dolphin
    okular
    libsForQt5.kdeconnect-kde # KDE connect
  ];

  # Exclude some default KDE plasma applications
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    #elisa
    #gwenview
    #okular
    #oxygen
    #khelpcenter
    konsole # we have a more sexy terminal
    #plasma-browser-integration
    #print-manager
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
  };
}
