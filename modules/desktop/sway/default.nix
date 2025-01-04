# closing screen still sleeps laptop?
# idle?
{ pkgs
, config
, username
, ...
}:
let
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
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
in
{
  imports = [
    ../components/waybar
    ../components/mako
    ../components/wofi
    ../components/clipman
    ../components/flashfocus
    # TODO: fix this
    # ../components/xdg-desktop-portal-termfilechooser
  ];

  environment.systemPackages = with pkgs; [
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
    flashfocus # Python script that flashes window I switch focus to
  ];

  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # Do not sleep on lid close
  # https://nixos.org/manual/nixos/stable/options#opt-services.logind.lidSwitch
  services.logind.lidSwitch = "ignore";

  # enable Sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;

    # clearout default packages
    extraPackages = [ ];

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=sway
      export XDG_CURRENT_DESKTOP=sway
    '';
  };

  services.libinput.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    # xdgOpenUsePortal = true;
    wlr.enable = true;
    wlr.settings.screencast = {
      # TODO: this is laptop only
      output_name = "eDP-1";
      chooster_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };

    # config.common = {
    #   default = "kde";
    #   "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    #   "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    #   "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    #   "org.freedesktop.portal.FileChooser" = [ "kde" ];
    # };
    #
    # config.sway = {
    #   default = pkgs.lib.mkForce "kde";
    #   # "org.freedesktop.impl.portal.Settings"=["luminous" "gtk"];
    #   "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
    # };

    # gtk portals backend implementations
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      # xdg-desktop-portal-hyprland
      # xdg-desktop-portal-shana
      # xdg-desktop-portal-wlr
      # xdg-desktop-portal-kde
    ];
  };

  # use greetd with tuigreet as login manager
  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --debug \
            --asterisks \
            --user-menu \
            --remember \
            --cmd sway
        '';
        user = "greeter";
      };
    };
  };

  networking.networkmanager.enable = true;
  services.blueman.enable = true;

  # symlink to sway config file in dotfiles repo
  home-manager.users.${username} =
    { config
    , pkgs
    , ...
    }: {
      # Services required for a smooth sway/waybar experience
      services.batsignal.enable = true;
      services.network-manager-applet.enable = true;

      services.blueman-applet.enable = true;
      home.packages = [ pkgs.dconf ];
      dconf.settings."org/blueman/plugins/powermanager".auto-power-on = false;

      stylix.targets.kde.enable = false;

      xdg.configFile = {
        "sway/config" = { source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/sway/config"; };

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
    };
}
