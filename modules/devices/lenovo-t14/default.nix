{
  hostname,
  username,
  lib,
  config,
  pkgs,
  nixos-hardware,
  ...
}: {
  # its a laptop!
  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
    ../../hardware/laptop
  ];

  # Update amd microcode
  hardware.cpu.amd.updateMicrocode = true;

  # Use Lenovo firmware blobs
  hardware.enableRedistributableFirmware = true;
}
