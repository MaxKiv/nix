{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  #----Host specific config ----
  my.networking.tailscale = {
    enable = true;
    nodeType = "client";
  };

  # Disable ASPM for the nassie NIC
  boot.extraModprobeConfig = ''
    options r8169 aspm=0
  '';

  networking = {
    networkmanager = {
      enable = true;
      # Disable NetworkManager's internal DNS resolution
      dns = "none";
    };

    # Disable ipv6, odido's 5g modem has a shitty impl
    enableIPv6 = false;
    useDHCP = false;
    dhcpcd.enable = false;
  };

  # Multi-boot system: use GRUB bootloader
  my.grub-bootloader.enable = true;

  # Install grub to the fallback path, nassie's current mobo doesn't boot without these 2
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
}
