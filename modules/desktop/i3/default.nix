{
  pkgs,
  lib,
  config,
  username,
  ...
}: {
  imports = [
    ../components/polybar
  ];

  environment.systemPackages = with pkgs; [
    xclip
    i3lock-fancy
    rofi
    rofimoji
    maim
  ];

  services.xserver = {
    enable = true;
    autorun = false;
  };
  services.displayManager = {
    enable = true;
    # startx.enable = true;
    defaultSession = "none+i3";
  };
  services.xserver.desktopManager = {
    xterm.enable = false;
  };

  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
  };

  # clipman
  services.greenclip.enable = true;

  # symlink to sway config file in dotfiles repo
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    # disable mouse acceleration
    home.file.".xinitrc".text = ''
      # Find and configure mouse
      # Replace "Your Mouse Name" with the actual name (partial match works)
      MOUSE_ID=$(xinput list | grep -i "Your Mouse Name" | grep -o "id=[0-9]*" | cut -d= -f2)
      if [ ! -z "$MOUSE_ID" ]; then
          # Disable acceleration
          xinput --set-prop $MOUSE_ID "libinput Accel Profile Enabled" 0, 1
          # Set sensitivity (0 is default, negative is slower, positive is faster)
          xinput --set-prop $MOUSE_ID "libinput Accel Speed" 0
          echo "Mouse configured"
      fi

      # Find and configure touchpad
      # Replace "Your Touchpad Name" with the actual name (partial match works)
      TOUCHPAD_ID=$(xinput list | grep -i "touchpad" | grep -o "id=[0-9]*" | cut -d= -f2)
      if [ ! -z "$TOUCHPAD_ID" ]; then
          # Enable tap to click
          xinput --set-prop $TOUCHPAD_ID "libinput Tapping Enabled" 1
          # Enable natural scrolling
          xinput --set-prop $TOUCHPAD_ID "libinput Natural Scrolling Enabled" 1
          # Disable while typing
          xinput --set-prop $TOUCHPAD_ID "libinput Disable While Typing Enabled" 0
          # Set tap button mapping (default is LMR)
          xinput --set-prop $TOUCHPAD_ID "libinput Tapping Button Mapping Enabled" 1, 0
          echo "Touchpad configured"
      fi

      i3
    '';

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };

    # used for wallpaper
    programs.feh.enable = true;

    # Services required for a smooth bar experience
    services.batsignal.enable = true;

    # Automount sd/usb
    services.udiskie.enable = true;

    # Enable the playerctld to be able to control music players and mpris-proxy to proxy bluetooth devices.
    services.playerctld.enable = true;
    services.mpris-proxy.enable = true;

    # Disable bluetooth on startup
    home.packages = [pkgs.dconf];
    dconf.settings."org/blueman/plugins/powermanager".auto-power-on = false;

    xdg.configFile = {
      "i3/config" = lib.mkForce {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/i3/config";
      };
    };
  };
}
