{
  pkgs,
  lib,
  config,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal # Desktop integration portals for sandboxed apps
  ];

  programs.sway = {
    extraSessionCommands = ''
      export XDG_DESKTOP_PORTAL_PREFFERED=kde
    '';
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;

    # TODO: this is laptop only
    wlr.settings.screencast = {
      output_name = "eDP-1";
      chooster_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };

    configPackages = [
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];

    config.sway = lib.mkForce {
      common = [
        "kde"
      ];
      default = [
        "kde"
        "wlr"
      ];
      file-chooser = [
        "kde"
      ];
    };

    # gtk portals backend implementations
    extraPortals = with pkgs; [
      # xdg-desktop-portal-gtk
      # xdg-desktop-portal-hyprland
      # xdg-desktop-portal-shana
      xdg-desktop-portal-wlr
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    # "xdg-desktop-portal-shana/config.toml" = {
    #   text = ''
    #   open_file = "Kde"
    #   save_file = "Kde"
    #
    #   [tips]
    #   open_file_when_folder = "Kde"
    #
    #   [file-dialog]
    #   # Show hidden files in the file dialog
    #   show-hidden = true
    #
    #   # Set the initial folder when the dialog opens
    #   initial-folder = "~/"
    #
    #   # Allow selecting multiple files at once
    #   allow-multiple = true
    #
    #   # Set dialog size (width x height in pixels)
    #   size = [800, 600]
    #
    #   # Enable bookmarks for quick navigation
    #   bookmarks = [
    #       "~/Downloads",
    #       "~/Pictures",
    #       "~/git"
    #       "~/projects"
    #   ]
    #   '';
    # };
  };
}
