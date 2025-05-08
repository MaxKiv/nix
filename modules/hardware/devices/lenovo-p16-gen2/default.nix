{
  hostname,
  username,
  lib,
  config,
  pkgs,
  ...
}: let
  nvidiaPkg = config.boot.kernelPackages.nvidiaPackages.stable;
in {
  # its a laptop!
  imports = [
    ../../laptop
  ];

  # Update intel microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Use Lenovo firmware blobs
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  services.xserver.videoDrivers = ["nvidia"];
  # services.xserver.videoDrivers = ["modesetting"];

  hardware.nvidia.package = nvidiaPkg;
  hardware.nvidia.open = lib.versionAtLeast nvidiaPkg.version "560" && false;

  # symlink the intel_gpu to /dev/intel_gpu
  services.udev.extraRules = ''
    KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="i915", SYMLINK+="dri/intel_gpu"
  '';

  # use the igpu
  environment.variables = {
    WLR_DRM_DEVICES = "/dev/dri/intel_gpu";
  };

  # Set up Nvidia GPU to use prime to use igpu and offload heavy compute to gpu
  hardware.nvidia = {
    nvidiaSettings = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # TODO try this
  # boot.kernelParams = ["module_blacklist=i915"];

  boot = {
    kernelModules = ["nvidia" "nvidia_drm" "nvidia_modeset" "nvidia_uvm"];
    initrd.kernelModules = ["nvidia" "nvidia_drm" "nvidia_modeset"]; # Critical for early KMS
    blacklistedKernelModules = ["nouveau"];

    extraModprobeConfig =
      "options nvidia "
      + lib.concatStringsSep " " [
        # nvidia assume that by default your CPU does not support PAT,
        # but this is effectively never the case in 2023
        "NVreg_UsePageAttributeTable=1"
        # This is sometimes needed for ddc/ci support, see
        # https://www.ddcutil.com/nvidia/
        #
        # Current monitor does not support it, but this is useful for
        # the future
        "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
      ];
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_EnableGpuFirmware=1" # Required for RTX 5000 series
  ];

  # environment.sessionVariables = {
  #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #   LIBVA_DRIVER_NAME = "nvidia";
  #   GBM_BACKEND = "nvidia-drm";
  # };

  # Setup CUDA dev toolkit
  # environment.systemPackages = with pkgs; [cudatoolkit];
}
