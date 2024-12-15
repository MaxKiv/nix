{ pkgs
, libs
, inputs
, ...
}: {
  specialisation = {
    hyprland.configuration = {
      programs.hyprland = {
        enable = true;
        package = inputs.hyprland.packages."${pkgs.system}".hyprland;
        xwayland.enable = true;
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };

      wayland.windowManager.hyprland = {
        enable = true;
        wayland.windowManager.hyprland.enableNvidiaPatches = true;
        settings = { };
      };

      systemd = {
        user.services.polkit-kde-authentication-agent-1 = {
          description = "polkit-kde-authentication-agent-1";
          wantedBy = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_kde}/libexec/polkit-kde-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
      };

      environment.systemPackages = with pkgs; [
        # file manager
        libsForQt5.dolphin
        # notification center
        #swaync
        dunst
        # screensharing
        pipewire
        wireplumber
        # auth agent
        polkilt-kde-agent
        # qt
        qt5-wayland
        qt6-wayland
        # bar
        waybar
        # app launcher
        wofi
      ];

      imports = [
        # ./waybar.nix
      ];
    };
  };
}
