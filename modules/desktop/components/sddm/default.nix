{
  pkgs,
  username,
  config,
  lib,
  ...
}: {
  options.my.sddm.autoLoginSession = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Session to autologin with SDDM.";
  };
  config = let
    autoLoginSession = config.my.sddm.autoLoginSession;
  in {
    environment.systemPackages = let
      custom-catppuccin-sddm = (
        pkgs.catppuccin-sddm.override {
          background = "${../../../../assets/backgrounds/nix-wallpaper-dracula.png}";
          loginBackground = true;
        }
      );
    in [
      custom-catppuccin-sddm
    ];

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm; # use kde6
        theme = "catppuccin-mocha";
        settings = {
          Autologin = {
            Session = autoLoginSession;
            User = "${username}";
          };
        };
      };

      defaultSession = "sway";
    };
  };
}
