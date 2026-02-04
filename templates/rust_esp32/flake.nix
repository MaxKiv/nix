{
  description = "ESP32 esp-idf/Rust Development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    rust-overlay.url = "github:oxalica/rust-overlay";

  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      esp-dev,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        esp32Outputs = import ./. {
          inherit
            self
            pkgs
            system
            esp-dev
            ;
        };

        defaultShell = {
          default = esp32Outputs.devShells.esp32;
        };
        devShells = esp32Outputs.devShells // defaultShell;
      in
      {
        inherit devShells;
        inherit (esp32Outputs) packages;
        inherit (esp32Outputs) apps;
      }
    );
}
