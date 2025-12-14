{hostname, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  #----Host specific config ----
  my.firefox = {
    enable = true;
  };

  # Multi-boot system: use GRUB bootloader
  my.grub-bootloader.enable = true;

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
}
