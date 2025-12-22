{
  hostname,
  username,
  lib,
  config,
  pkgs,
  inputs,
  ...
}: {
  # its a laptop!
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t440s
    ../../laptop
  ];

  # Update amd microcode
  hardware.cpu.amd.updateMicrocode = true;

  # Use Lenovo firmware blobs
  hardware.enableRedistributableFirmware = true;
}
