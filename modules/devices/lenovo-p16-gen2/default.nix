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

  hardware.nvidia.package = nvidiaPkg;
  hardware.nvidia.open = lib.versionAtLeast nvidiaPkg.version "560" && false;

  # Set up Nvidia GPU to use prime to use igpu and offload heavy compute to gpu
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Setup CUDA dev toolkit
  environment.systemPackages = with pkgs; [cudatoolkit];

  # Multi-boot system: use GRUB bootloader
  my.grub-bootloader.enable = true;
}
