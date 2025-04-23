{
  config,
  username,
  lib,
  ...
}:
with lib; {
  options.my.grub-bootloader.enable = mkEnableOption "Use the GRUB bootloader";

  config = let
    cfg = config.my.grub-bootloader.enable;
  in
    mkMerge [
      # Configuration to apply when option is enabled
      (mkIf cfg {
        boot.loader.systemd-boot.enable = false;
        boot.loader.grub.enable = true;
        boot.loader.grub.configurationLimit = 10;
        boot.loader.grub.devices = ["nodev"];
        boot.loader.grub.useOSProber = true;
        boot.loader.grub.efiSupport = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.efi.efiSysMountPoint = "/boot"; # default
      })

      # Configuration to apply when option is disabled. NOTE: mkEnableOption defaults to false!
      (mkIf (!cfg) {
        boot.loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
          };
        };

        console.earlySetup = true;
      })
    ];
}
