{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
    libvlc
  ];
}
