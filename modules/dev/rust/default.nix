{
  config,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    cargo
    rustc
    rustup
    rustfmt
    clippy
    rust-analyzer
    cargo-generate
    cargo-binutils
  ];
}
