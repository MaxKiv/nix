{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  my.firefox = {
    enable = true;
  };

  my.displaylink.enable = true;

  my.networking.can.interfaces = {
    can0 = {
      bitrate = 250000;
    };
  };
}
