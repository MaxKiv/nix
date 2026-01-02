{
  pkgs,
  libs,
  inputs,
  username,
  ...
}: {
  imports = [
    ../components/wofi
    ../components/clipman
    # ../components/clipvault
    ../components/swappy
    # ../components/xdg-portals
    ../components/playerctld
    ../components/tumbler
    ../components/mako
    ../components/waybar
  ];

  environment.systemPackages = with pkgs; [
    wev # wayland event viewer (find out key names)
    notify-desktop # provides the notify-send binary to trigger mako
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard-rs # wl-copy and wl-paste for copy/paste from stdin / stdout
    brightnessctl # CLI to control brightness
    networkmanager # Manage wireless networks
    pulsemixer # CLI to control puleaudio
    alsa-utils # for amixer to mute mic
    wdisplays # xrandr type gui to mess with monitor placement
    libinput # Handles input devices in Wayland compositors
    libinput-gestures # Gesture mapper for libinput
    tesseract # OCR engine
  ];

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # use greetd with tuigreet as login manager
  services.greetd = {
    enable = true;
    restart = true;
    # vt = 2;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd hyprland";
        user = "greeter";
      };
    };
  };

  # Plumb hyprlock to PAM
  security = {
    polkit.enable = true;
    pam.services = {
      hyprlock = {};
    };
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
  };

  services = {
    gnome = {
      gnome-keyring.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # Automount sd cards backend
    udisks2.enable = true;

    # Frontend for udisks2 sd/usb automount
    # Automount "devices"
    devmon.enable = true;

    # Set up upower to be able to get battery levels of connected devices.
    upower.enable = true;

    # Filesystem interface implemented by local/remote fileSystems: Mount, trash, and other functionalities for file explorer
    gvfs.enable = true;
  };

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    services = {
      hyprpolkitagent.enable = true;

      # Automount sd/usb
      udiskie = {
        enable = true;
        tray = "always";
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      # import system environment in systemd
      systemd.variables = ["--all"];

      settings = {
        # Do the debug thing
        debug = {
          disable_logs = false;
          enable_stdout_logs = true;
        };

        general = {
          no_focus_fallback = true;
        };

        env = [
          "LIBVA_DRIVER_NAME,nvidia"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
          "CLUTTER_BACKEND,wayland"
          "GDK_QPA_PLATFORM,wayland;xcb"
          "SDL_VIDEODRIVER,wayland"
          "XDG_SESSION_TYPE,wayland"
        ];

        ####################
        # Variables
        ####################
        "$mod" = "SUPER";

        "$term" = "alacritty";
        "$browser" = "firefox";
        "$menu" = "wofi --show drun --prompt search";
        "$emoji" = "wofi-emoji";
        "$file" = "alacritty -e yazi";
        "$top" = "alacritty -e zenith";
        "$system" = "alacritty -e zellij attach nix";
        "$notes" = "alacritty -e zellij attach notes";
        "$lock" = "hyprlock";

        ####################
        # Autostart
        ####################
        exec-once = [
          "waybar"
          "nm-applet --indicator"
          "blueman-applet"
          # "wl-paste --watch clipvault store --min-entry-length 2 --max-entries 200 --max-entry-age 2d"
        ];

        ####################
        # Monitors (native replacement for kanshi)
        ####################
        monitor = [
          # Laptop / single monitor example
          # "eDP-1,highrgr,auto,1"
          # Home
          "desc:Philips Consumer Electronics Company 25M2N3200W UK02314010834,1920x1080@240.006,auto,1"
          # "HDMI-A-2,highrr,auto,1"
          # Others
          ", preferred, auto, 1"
        ];

        ####################
        # General layout
        ####################
        general = {
          layout = "dwindle";
          gaps_in = 2;
          gaps_out = 1;
          border_size = 0;
        };

        decoration = {
          rounding = 10;
          dim_inactive = true;
          dim_strength = 0.2;
          shadow = {
            enabled = true;
          };
          blur = {
            enabled = false;
          };
        };

        animations = {
          enabled = false;
        };

        misc = {
          disable_hyprland_logo = true;
          focus_on_activate = true;
        };

        ####################
        # Input
        ####################
        input = {
          repeat_delay = 250;
          repeat_rate = 75;

          accel_profile = "flat";
          sensitivity = 0;

          touchpad = {
            natural_scroll = true;
            tap-to-click = true;
            disable_while_typing = false;
          };
        };

        cursor = {
          inactive_timeout = 50;
        };

        ####################
        # Window rules (v2)
        ####################
        windowrulev2 = [
          "float,class:^(blueman-manager)$"
          "size 960 540,class:^(blueman-manager)$"

          "float,class:^(com.gabm.satty)$"
          "size 1280 1024,class:^(com.gabm.satty)$"

          "float,class:^(swappy)$"
          "size 1280 1024,class:^(swappy)$"

          "float,title:^(.*Bitwarden.*)$"
        ];

        ####################
        # Keybindings
        ####################
        bind = [
          # Launchers
          "$mod,Return,exec,$term"
          "$mod,D,exec,$menu"
          "$mod,E,exec,$file"
          "$mod,B,exec,$browser"
          "$mod,I,exec,$system"
          "$mod,N,exec,$notes"
          "$mod,period,exec,$emoji"
          "$mod CTRL,L,exec,$lock"

          # Lifecycle
          "$mod,Q,killactive"
          "$mod SHIFT,R,exec,hyprctl reload"
          "$mod SHIFT,E,exit"

          # Layout / state
          "$mod,F,fullscreen"
          "$mod SHIFT,SPACE,togglefloating"

          # Focus (hjkl)
          "$mod,H,movefocus,l"
          "$mod,J,movefocus,d"
          "$mod,K,movefocus,u"
          "$mod,L,movefocus,r"

          # Move windows
          "$mod SHIFT,H,movewindow,l"
          "$mod SHIFT,J,movewindow,d"
          "$mod SHIFT,K,movewindow,u"
          "$mod SHIFT,L,movewindow,r"

          # Workspaces
          "$mod,1,workspace,1"
          "$mod,2,workspace,2"
          "$mod,3,workspace,3"
          "$mod,4,workspace,4"
          "$mod,5,workspace,5"
          "$mod,6,workspace,6"
          "$mod,7,workspace,7"
          "$mod,8,workspace,8"
          "$mod,9,workspace,9"
          "$mod,0,workspace,10"
          "$mod,-,workspace,11"
          "$mod,=,workspace,12"

          "$mod SHIFT,1,movetoworkspacesilent,1"
          "$mod SHIFT,2,movetoworkspacesilent,2"
          "$mod SHIFT,3,movetoworkspacesilent,3"
          "$mod SHIFT,4,movetoworkspacesilent,4"
          "$mod SHIFT,5,movetoworkspacesilent,5"
          "$mod SHIFT,6,movetoworkspacesilent,6"
          "$mod SHIFT,7,movetoworkspacesilent,7"
          "$mod SHIFT,8,movetoworkspacesilent,8"
          "$mod SHIFT,9,movetoworkspacesilent,9"
          "$mod SHIFT,0,movetoworkspacesilent,10"
          "$mod SHIFT,-,movetoworkspacesilent,11"
          "$mod SHIFT,=,movetoworkspacesilent,12"

          "$mod CTRL_SHIFT,H,resizeactive,10 0%"
          "$mod CTRL_SHIFT,J,resizeactive,0 10%"
          "$mod CTRL_SHIFT,K,resizeactive,-10 0%"
          "$mod CTRL_SHIFT,L,resizeactive,0 -10%"

          "$mod,o,workspace,previous"
          "$mod,TAB,workspace,m+1"
          "$mod SHIFT,TAB,workspace,m-1"

          ####################
          # Clipboard
          ####################
          # ''$mod, V, exec, clipvault list | wofi -S dmenu --pre-display-cmd "echo '%s' | cut -f 2" | clipvault get | wl-copy''
          ''$mod, V, exec, clipman pick -t wofi --histpath="~/.local/share/clipman.json"''

          ####################
          # Screenshots
          ####################
          "$mod SHIFT,S,exec,grim -g \"$(slurp -d)\" - | wl-copy"
          "$mod CTRL,S,exec,grim -g \"$(slurp)\" - | swappy -f -"
          "$mod SHIFT,T,exec,grim -g \"$(slurp -d)\" - | tee /tmp/ocr.png | tesseract stdin stdout | wl-copy"

          ####################
          # Brightness
          ####################
          ",XF86MonBrightnessUp,exec,brightnessctl set 5%+"
          ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"

          ####################
          # Audio
          ####################
          ",XF86AudioMute,exec,pulsemixer --toggle-mute"
          ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 1"
          ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1"
          ",XF86AudioMicMute,exec,amixer set Capture toggle"

          ####################
          # Media
          ####################
          ",XF86AudioPlay,exec,playerctl play-pause"
          ",XF86AudioNext,exec,playerctl next"
          ",XF86AudioPrev,exec,playerctl previous"
        ];
      };
    };

    # Hyprland lockscreen utility
    programs.hyprlock = {
      enable = true;
    };
  };
}
