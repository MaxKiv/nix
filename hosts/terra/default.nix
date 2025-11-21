{
  imports = [
    ./hardware-configuration.nix
  ];

  #----Host specific config ----
  my.firefox = {
    enable = true;
  };

  # Multi-boot system: use GRUB bootloader
  my.grub-bootloader.enable = true;
}
