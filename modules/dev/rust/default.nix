{ config, pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
    cargo
    rustc
    rustfmt
    clippy
    cargo-generate
    cargo-binutils
  ];
}
