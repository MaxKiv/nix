{
  description = "Your new Rust project";

  inputs = {
    your-nixos-flake.url = "github:maxkiv/nix";
    nixpkgs.follows = "your-nixos-flake/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Outputs this flake produces
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    fenix,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = (import nixpkgs) {
        inherit system;
      };

      # Get a cross compilation toolchain from the rust-toolchain.toml
      toolchain = with fenix.packages.${system};
        fromToolchainFile {
          file = ./rust-toolchain.toml; # alternatively, dir = ./.;
          sha256 = "sha256-ZA6pnlKaGAT8PnsZp/cgNB9N/tCls9mfvAXEuRylX6I=";
        };
    in {
      # Development shells provided by this flake, to use:
      # nix develop .#default
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          nil # Nix LSP
          alejandra # Nix Formatter
          toolchain # Our Rust toolchain
          rust-analyzer # Rust LSP
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    });
}
