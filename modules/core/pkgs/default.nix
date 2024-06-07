{ pkgs, ... }:

{
  # Default system packages
  environment.systemPackages = with pkgs; [
    sops
    cowsay
    neofetch
    eza
    git
    wget
    unzip
    xclip
    bat # the better cat
    ripgrep # the better grep
    fd # the better find
    findutils # locate etc
    tree
    glow # md reader
    coreutils
    killall
    home-manager
    brightnessctl
    playerctl
    gparted
    kalker # cmdline calculator
    just
    bitwarden-cli
    asciiquarium
    lshw # Detailed info on connected hardware
    busybox # unix utilities
    toybox # unix utilities
    usbutils # lsusb
    pciutils # inspecting and manipulating configuration of PCI devices
    cachix # nix binary cache cli
    nix-ld # Run unpatched dynamic binaries on NixOS
    appimage-run # Setup common unix libs required to run appimages on nixos
    exercism # exercism cli
  ];
}
