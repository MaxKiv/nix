{
  description = "My new project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  # Outputs this flake produces
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = (import nixpkgs) {
        inherit system;
      };
    in {
      # Development shells provided by this flake, to use:
      # nix develop .#default
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          nil # nix LSP
          nixpkgs-fmt # nil uses this and I cant be bothered to change it
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    });
}
