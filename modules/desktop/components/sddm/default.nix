{
  pkgs,
  username,
  lib,
  ...
}: {
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
          Session = "sway";
          User = "${username}";
        };
      };
    };

    defaultSession = "sway";
  };
}
