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
    ../../hardware/laptop
  ];

  # Update intel microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Use Lenovo firmware blobs
  hardware.enableRedistributableFirmware = true;

  # hardware.nvidia.package = nvidiaPkg;
  # hardware.nvidia.open = lib.versionAtLeast nvidiaPkg.version "560" && false;

  # symlink the intel_gpu to /dev/intel_gpu
  services.udev.extraRules = ''
    KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="i915", SYMLINK+="dri/intel_gpu"
  '';

  # use the igpu
  environment.variables = {
    WLR_DRM_DEVICES = "/dev/dri/intel_gpu";
  };

  boot.kernelParams = [
    "module_blacklist=nouveau,nvidia,nvidia_drm,nvidia_modeset"
    "rd.driver.blacklist=nouveau,nvidia,nvidia_drm,nvidia_modeset"
    "modprobe.blacklist=nouveau,nvidia,nvidia_drm,nvidia_modeset"
    "nouveau.modeset=0"
    "pci=nocrs" # Can help with some problematic devices
    # Add your existing parameters from above
    # This ignores the PCI device at 01:00.0 (your NVIDIA GPU)
    "pci=noaer"
    "pcie_aspm=off"
    "pci-stub.ids=10de:XXXX" # Replace XXXX with your specific NVIDIA device ID
  ];

  # Blacklist the modules explicitly
  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset"
    "nvidia_uvm"
  ];

  # boot.kernelParams = [
  #   "nvidia-drm.modeset=1"
  #   "nvidia-drm.fbdev=1"
  # ];
  # boot.kernelModules = [
  #   "nvidia"
  #   "nvidia_uvm"
  #   "nvidia_modeset"
  #   "nvidia_drm"
  #   "xe"
  # ];

  # Set up Nvidia GPU to use prime to use igpu and offload heavy compute to gpu
  # services.xserver.videoDrivers = ["modesetting"];
  # services.xserver.videoDrivers = ["nvidia"];
  # hardware.nvidia = {
  #   nvidiaSettings = false;
  #   modesetting.enable = true;
  #   powerManagement.enable = true;
  #   prime = {
  #     offload.enable = true;
  #     intelBusId = "PCI:0:2:0";
  #     nvidiaBusId = "PCI:1:0:0";
  #   };
  # };

  # environment.sessionVariables = {
  #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #   LIBVA_DRIVER_NAME = "nvidia";
  #   GBM_BACKEND = "nvidia-drm";
  # };

  # Setup CUDA dev toolkit
  # environment.systemPackages = with pkgs; [cudatoolkit];

  # Multi-boot system: use GRUB bootloader
  # my.grub-bootloader.enable = true;
}
