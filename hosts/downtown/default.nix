{
  imports = [
    ./hardware-configuration.nix
  ];

  #----Host specific config ----
  my.firefox = {
    enable = true;
  };
}
