{
  imports = [
    ./hardware-configuration.nix
  ];

  #----Host specific config ----
  my.powerManager = "auto-cpufreq";

  my.firefox = {
    enable = true;
  };

  my.networking.can.interfaces = {
    can0 = {
      bitrate = 250000;
    };
  };
  
  # Multi-boot system: use GRUB bootloader
  my.grub-bootloader.enable = true;
}
