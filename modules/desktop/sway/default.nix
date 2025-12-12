{
  pkgs,
  lib,
  config,
  username,
  ...
}: let
  # bash script to let dbus know about important env variables and
  # propagate them to relevant services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  sway-launch-or-focus = pkgs.writeShellScriptBin "sway-launch-or-focus" ''
    #!/bin/bash

    # Input parameters
    WORKSPACE="$1"
    APP_IDENTIFIER="$2"
    APP_COMMAND="$3"

    if [ -z "$WORKSPACE" ] || [ -z "$APP_IDENTIFIER" ] || [ -z "$APP_COMMAND" ]; then
      echo "Usage: $0 <workspace> <app_identifier> <app_command>"
      exit 1
    fi

    # Check if the application is in any workspace's representation
    FOUND_WORKSPACE=$(swaymsg -t get_workspaces | jq -r \
        '.[] | select(.name == "'"$WORKSPACE"'") | select(.representation | test("'"$APP_IDENTIFIER"'")) | .name')

    if [ -n "$FOUND_WORKSPACE" ]; then
        # echo Application is found, focus the workspace
        swaymsg workspace "$WORKSPACE"
    else
        # echo Application not found, launch it in the specified workspace
        swaymsg workspace "$WORKSPACE"
        exec $APP_COMMAND &
    fi
  '';
in {
  imports = [
    ../components/waybar
    ../components/mako
    ../components/wofi
    ../components/clipman
    ../components/swappy
    ../components/xdg-portals
    ../components/playerctld
    ../components/tumbler
  ];

  environment.systemPackages = with pkgs;
    [
      dbus-sway-environment
      sway-launch-or-focus
      wev # wayland event viewer (find out key names)
      notify-desktop # provides the notify-send binary to trigger mako
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard-rs # wl-copy and wl-paste for copy/paste from stdin / stdout
      xclip # TODO: figure out why I still need this
      # mako # notification system developed by swaywm maintainer
      swaylock-fancy # Fancy lock screen
      # swayidle # Idle management daemon for wayland
      # sway-audio-idle-inhibit # block swayidle when audio is playing
      # glib # for gsettings
      # gtk3.out # for gtk-launch
      libinput # Handles input devices in Wayland compositors
      libinput-gestures # Gesture mapper for libinput
      brightnessctl # CLI to control brightness
      networkmanager # Manage wireless networks
      # networkmanagerapplet # System tray GUI for networkmanager
      pulsemixer # CLI to control puleaudio
      alsa-utils # for amixer to mute mic
      # power-profiles-daemon # make power profiles available over D-Bus
      wdisplays # xrandr type gui to mess with monitor placement
      wl-mirror # simple wayland display mirror program
      # kanshi # hotswap monitors, wayland arandr, in its own module now
    ]
    # Add some KDE packages I have become used to
    ++ (with kdePackages; [
      konsole
      ark
      dolphin
      dolphin-plugins
      gwenview
      kdegraphics-thumbnailers
      kfilemetadata
      kimageformats
      qtimageformats
      kio
      kio-admin
      kio-extras
      kio-fuse
      kservice
      libheif
      okular
      polkit-kde-agent-1
      # plasma-workspace
      qtwayland
      kdialog
      tesseract # OCR engine
    ]);

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

  # use greetd with tuigreet as login manager
  services.greetd = {
    enable = true;
    restart = true;
    # vt = 2;
    settings = {
      default_session = {
        # command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd 'sway --unsupported-gpu'";
        # command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd '${pkgs.swayfx}/bin/sway --unsupported-gpu'";
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd ${pkgs.writeScript "start-sway" ''
          export XDG_SESSION_TYPE=wayland
          export SDL_VIDEODRIVER=wayland
          export QT_QPA_PLATFORM=wayland
          export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          export _JAVA_AWT_WM_NONREPARENTING=1
          export MOZ_ENABLE_WAYLAND=1
          export XDG_SESSION_TYPE=wayland
          export XDG_SESSION_DESKTOP=sway
          export XDG_CURRENT_DESKTOP=sway
          export XDG_DESKTOP_PORTAL_PREFFERED=wlr

          exec dbus-run-session -- sway --unsupported-gpu
        ''}";
        user = "greeter";
      };
    };
  };

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;
  # Must be enabled for home-manager sway
  security.polkit.enable = true;
  security.pam = {
    services.greetd = {
      enableGnomeKeyring = true;
      sshAgentAuth = true;
    };
    sshAgentAuth.enable = true;
  };

  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;

    # These are the flags GDM will use when launching sway
    extraOptions = [
      "--unsupported-gpu"
    ];

    extraPackages = [];
  };

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    # enable Sway window manager
    wayland.windowManager.sway = {
      enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
        variables = [
          "--all"
        ];
      };

      package = pkgs.swayfx;
      extraOptions = ["--unsupported-gpu"];

      # Get rid of the default config, I overwrite this in my own config below
      config = {
        keybindings = {};
        modifier = "Mod4";
        modes = {};
        bars = [];
      };

      # Tell sway to include my config
      extraConfig = ''
        include ~/.config/sway/config.d/*.conf
      '';

      wrapperFeatures.gtk = true;
      xwayland = true;

      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=sway
        export XDG_CURRENT_DESKTOP=sway
        export XDG_DESKTOP_PORTAL_PREFFERED=wlr
      '';

      # This check fails for reasons unknown, see:
      # https://github.com/nix-community/home-manager/issues/5379
      checkConfig = false;
    };

    # Enable kanshi display management daemon
    services.kanshi = {
      enable = true;
      systemdTarget = "sway-session.target";
      settings = [
        {
          profile = {
            name = "default";
            outputs = [
              {
                criteria = "Philips Consumer Electronics Company 25M2N3200W UK02314010834";
                status = "enable";
                mode = "1920x1080@240.006Hz";
                scale = 1.0;
              }
            ];
          };
        }
      ];
    };

    # Services required for a smooth sway/waybar experience
    # TODO: only start on laptops
    services.batsignal.enable = true;

    # Automount sd/usb
    services.udiskie = {
      enable = true;
      tray = "always";
    };

    # Enable the playerctld to be able to control music players and mpris-proxy to proxy bluetooth devices.
    services.playerctld.enable = true;
    services.mpris-proxy.enable = true;

    home.packages = [pkgs.dconf];
    dconf.settings."org/blueman/plugins/powermanager".auto-power-on = false;

    # symlink to sway config file in dotfiles repo
    xdg.configFile."sway/config.d/99-user.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/sway/config";
    };

    # Block auto-sway reload, Sway crashes if allowed to reload this way.
    xdg.configFile."sway/config".onChange = lib.mkForce "";
  };
}
