{
  imports = [
    ./hardware-configuration.nix
  ];

  #----Host specific config ----
  my.powerManager = "auto-cpufreq";

  my.firefox = {
    enable = true;
  };

  my.networking.tailscale = {
    enable = true;
    nodeType = "client";
  };

  networking = {
    networkmanager = {
      enable = true;
      # Disable NetworkManager's internal DNS resolution
      dns = "none";
    };

    # Disable ipv6, odido's 5g modem has a shitty impl
    enableIPv6 = false;
    useDHCP = false;
    dhcpcd.enable = false;
  };

  # Multi-boot system: use GRUB bootloader
  my.grub-bootloader.enable = true;
}
