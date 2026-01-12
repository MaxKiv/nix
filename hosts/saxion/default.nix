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

  # my.displaylink.enable = true;

  my.networking.can.interfaces = {
    can0 = {
      bitrate = 250000;
    };
  };

  #----Host specific config ----
  my.powerManager = "auto-cpufreq";

  my.firefox = {
    enable = true;
  };

  # Multi-boot system: use GRUB bootloader
  my.grub-bootloader.enable = true;

  my.networking.tailscale = {
    enable = true;
    nodeType = "client";
  };

  networking = {
    networkmanager = {
      enable = true;
      # Disable NetworkManager's internal DNS resolution
      dns = lib.mkForce "none";
    };

    enableIPv6 = false;
    useDHCP = false;
    dhcpcd.enable = false;
  };
}
