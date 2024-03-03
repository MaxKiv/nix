{ pkgs, ... }:

{
  # Default system packages
  environment.systemPackages = with pkgs; [
    sops
    cowsay
    neofetch
    eza
    lshw # Detailed info on connected hardware
    git
    wget
    unzip
    cmake
    gnumake
    clang_17
    clang-tools_17
    cargo
    python3
    ruby
    nodejs_21
    xclip
    bat # the better cat
    ripgrep # the better grep
    fd # the better find
    findutils # locate etc
    tree
    glow # md reader
    coreutils
    killall
    lua
    home-manager
    brightnessctl
    playerctl
    gparted
    kalker
    just
    bitwarden-cli
  ];
}
