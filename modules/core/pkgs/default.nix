{ pkgs, ... }:

{
  # Default system packages
  environment.systemPackages = with pkgs; [
    home-manager # manage my home dir/programs
    sops # manage my nixos secrets
    cowsay # very important
    neofetch # very important
    eza # better ls
    git # its git
    wget # get stuff from the web
    xclip # clipboard binary
    bat # the better cat
    ripgrep # the better grep
    fd # the better find
    findutils # locate etc
    tree # we love green
    glow # md reader
    coreutils # its coreutils
    killall # when you need a shotgun
    brightnessctl # CLI for brightness
    playerctl # CLI to control media players
    gparted # manage disk partitions
    kalker # cmdline calculator
    just # simple cmd runner
    bitwarden-cli # CLI for bitwarden
    asciiquarium # very important
    lshw # Detailed info on connected hardware
    busybox # unix utilities
    toybox # unix utilities
    usbutils # lsusb
    pciutils # inspecting and manipulating configuration of PCI devices
    cachix # nix binary cache cli
    nix-ld # Run unpatched dynamic binaries on NixOS
    appimage-run # Setup common unix libs required to run appimages on nixos
    exercism # exercism cli
    zenith # htop replacement
    chafa # show images in terminal
    zip # zip stuff
    unzip # unzip stuff
    yt-dlp # youtube-dl fork
    inkscape
  ];
}
