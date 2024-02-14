{ pkgs, ... }: {

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  services.xserver.desktopManager.plasma5.enable = true;
  # sddm is recommended for plasma5
  services.xserver.displayManager.sddm.enable = true;

  # KDE system packages
  environment.systemPackages = with pkgs; [
    #hicolor_icon_theme
    kleopatra
    kdeconnect
    spectacle
    gwenview
    dolphin
    okular
    #networkmanager-qt
    #pavucontrol-qt
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

}
