{
  description = "Pyton project";

  inputs = {
    your-nixos-flake.url = "github:maxkiv/nix";
    nixpkgs.follows = "your-nixos-flake/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  # Outputs this flake produces
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    poetry2nix,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = (import nixpkgs) {
        inherit system;
      };

      poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs;};

      # Use poetry2nix to create a Python environment from pyproject.toml
      pythonEnv = poetry2nix.mkPoetryEnv {
        projectDir = ./.;
        preferWheels = true;
      };

    in {
      # Development shells provided by this flake, to use:
      # nix develop .#default
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          nil # nix LSP
          alejandra # nix Formatter

          # Python environment with dependencies from pyproject.toml
          pythonEnv

          # Poetry for dependency management
          poetry

          # Basedpyright (Pyright wrapper) for LSP support
          basedpyright

          # Additional development tools (optional)
          black
          isort
          python312Packages.flake8
          python312Packages.pytest
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    });
}
