{
  imports = [
    ./hardware-configuration.nix
  ];

  #----Host specific config ----
  my.powerManager = "auto-cpufreq";

  my.firefox = {
    enable = true;
  };
}
