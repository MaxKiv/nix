{
  hostname,
  username,
  pkgs,
  ...
}: {
  # Ensure latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Ensure latest firmware is in there
  hardware.enableAllFirmware = true;

  # Enable firmware updates
  services.fwupd.enable = true;

  # Select Power manager
  my.powerManager = "auto-cpufreq";

  # Prevent overheating, manage thermals
  services.thermald.enable = true;

  # Enable thunderbolt
  services.hardware.bolt.enable = true;

  # Trackpad
  services.libinput.enable = true;

  # Battery stats
  services.upower.enable = true;

  # Do not sleep on lid close
  # https://nixos.org/manual/nixos/stable/options#opt-services.logind.lidSwitch
  services.logind.settings.Login.HandleLidSwitch = "ignore";
}
