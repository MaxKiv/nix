{ inputs, pkgs, ... }: {

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # services.xserver.desktopManager.plasma5.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    theme = "where_is_my_sddm_theme";
  };

  # KDE system packages
  environment.systemPackages = with pkgs; [
    (
      pkgs.where-is-my-sddm-theme.override {
        themeConfig.General = {
          background = "${../../../assets/backgrounds/sunset.png}";
          backgroundMode = "fill";
          cursorColor = "#ffffff";
        };
      })
    #hicolor_icon_theme
    kleopatra
    spectacle
    gwenview
    dolphin
    okular
    libnotify
    #xclip
    wl-clipboard-rs
  ];

  programs.kdeconnect.enable = true;

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
