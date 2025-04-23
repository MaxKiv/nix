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

  # Power management, sensible default
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #
  #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  #
  #     CPU_MIN_PERF_ON_AC = 0;
  #     CPU_MAX_PERF_ON_AC = 100;
  #     CPU_MIN_PERF_ON_BAT = 0;
  #     CPU_MAX_PERF_ON_BAT = 20;
  #
  #     # Optional helps save long term battery health
  #     # START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
  #     # STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
  #   };
  # };

  # Power manager, seems better on wayland?
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Prevent overheating, manage thermals
  services.thermald.enable = true;

  # Enable thunderbolt
  services.hardware.bolt.enable = true;

  # Trackpad
  services.xserver.libinput.enable = true;

  # Battery stats
  services.upower.enable = true;

  # Do not sleep on lid close
  # https://nixos.org/manual/nixos/stable/options#opt-services.logind.lidSwitch
  services.logind.lidSwitch = "ignore";
}
