{ pkgs, username, lib, home-manager, ... }:
{
  # This contains everything that should be in an iso
  imports = [
    home-manager.nixosModules.home-manager
    ../../modules/core
    ../../modules/hardware/sound
    ../../modules/hardware/bluetooth
  ];

  # Iso specific settings
  isoImage.volumeID = lib.mkForce "LiveNix";
  isoImage.isoName = lib.mkForce "LiveNix.iso";

  # Use zstd instead of xz for compressing the liveUSB image, it's 6x faster and 15% bigger.
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # FIX for running out of space / tmp, which is used for building
  fileSystems."/nix/.rw-store" = {
    fsType = "tmpfs";
    options = [ "mode=0755" "nosuid" "nodev" "relatime" "size=14G" ];
    neededForBoot = true;
  };


  # Override user
  users.users.${username} = {
    shell = pkgs.bash;
    isNormalUser = true;
    initialPassword = "Proverdi12";
    extraGroups = [ "wheel" "input" "video" "render" ];
  };

  services.getty.autologinUser = lib.mkForce "${username}";
}
