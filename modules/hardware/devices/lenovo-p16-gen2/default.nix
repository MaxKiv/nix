{
  hostname,
  username,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../laptop
  ];

  # Update intel microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Use Lenovo firmware blobs
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  services.xserver.videoDrivers = ["nvidia"];

  # Make wlroots render using the igpu and copy to the dgpu (which is connected to the external hdmi)
  environment.variables = {
    WLR_DRM_DEVICES = "/dev/dri/igpu:/dev/dri/dgpu";
  };

  # Set up Nvidia prime to use igpu by default and offload heavy compute to gpu
  # Take a look at: https://github.com/TLATER/dotfiles/blob/master/nixos-modules/nvidia/prime.nix
  hardware.nvidia = {
    nvidiaSettings = true;
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    open = true;
    # dynamicBoost.enable = true;
    prime = lib.mkForce {
      # sync.enable = true;
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Set up a udev rule to create named symlinks for the pci paths.
  # This is necessary because wlroots splits the DRM_DEVICES on
  # `:`, which is part of the pci path.
  # This is the magic sauce that makes sway work on both i/dgpu for the p16g2
  services.udev.packages = let
    pciPath = xorgBusId: let
      components = lib.drop 1 (lib.splitString ":" xorgBusId);
      toHex = i: lib.toLower (lib.toHexString (lib.toInt i));

      domain = "0000"; # Apparently the domain is practically always set to 0000
      bus = lib.fixedWidthString 2 "0" (toHex (builtins.elemAt components 0));
      device = lib.fixedWidthString 2 "0" (toHex (builtins.elemAt components 1));
      function = builtins.elemAt components 2; # The function is supposedly a decimal number
    in "dri/by-path/pci-${domain}:${bus}:${device}.${function}-card";

    pCfg = config.hardware.nvidia.prime;
    igpuPath = pciPath (
      if pCfg.intelBusId != ""
      then pCfg.intelBusId
      else pCfg.amdgpuBusId
    );
    dgpuPath = pciPath pCfg.nvidiaBusId;
  in
    lib.singleton (
      pkgs.writeTextDir "lib/udev/rules.d/61-gpu-offload.rules" ''
        SYMLINK=="${igpuPath}", SYMLINK+="dri/igpu"
        SYMLINK=="${dgpuPath}", SYMLINK+="dri/dgpu"
      ''
    );

  boot.initrd.kernelModules = ["nvidia"];

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_EnableGpuFirmware=1" # Required for RTX 5000 series
  ];

  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
  };
}
