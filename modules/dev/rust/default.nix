{ config, pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
    cargo
    rustc
    rustup
    rustfmt
    clippy
    cargo-generate
    cargo-binutils
  ];
}
