# Kanshi is a daemon to hotswap monitors, defaults to sway
{username, ...}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      # kanshi
      wl-mirror
    ];

    services.kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";

      # xdg.configFile = {
      #   "kanshi/config" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/kanshi/config";};
      # };

      # hyprctl monitors all
      profiles = {
        work_undocked = {
          outputs = [
            {
              criteria = "eDP-1";
              scale = 1.3;
              status = "enable";
            }
          ];
        };

        undocked = {
          outputs = [
            {
              criteria = "eDP-1";
              scale = 1.0;
              status = "enable";
            }
          ];
        };

        work = {
          outputs = [
            {
              criteria = "Dell Inc. DELL U2518D 3C4YP8BH245L";
              position = "0,0";
              mode = "2560x1440@59.951Hz";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };

        home = {
          outputs = [
            {
              criteria = "Philips Consumer Electronics Company 25M2N3200W UK02314010834";
              position = "0,0";
              mode = "1920x1080@240.006Hz";
            }
          ];
        };
      };
    };
  };
}
