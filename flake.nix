# Much of the flake structure is shamelessly stolen from
# https://github.com/erictossell/nixflakes/blob/main/flake.nix
{
  description = "MaxKiv's Nixos config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-utils.url = "github:numtide/flake-utils";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };

    # source = "https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml";
    alacritty-catppuccin = {
      url = "github:catppuccin/alacritty";
      flake = false;
    };

    # NixOS-WSL = {
    #   url = "github:nix-community/NixOS-WSL";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # hardware.url = "github:nixos/nixos-hardware";

  };

  outputs = { self, nixpkgs, home-manager, nixos-generators, ... } @ attrs:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      username = "max";
    in
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {

        boston =
          let system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            specialArgs = {
              hostname = "boston";
              type = "desktop";
              inherit system username;
            } // attrs;
            modules = [
              # import default modules through default.nix
              ./.
              # Specify host specific modules
              ./modules/hardware/network
              ./modules/hardware/nvidia
              ./modules/desktop/kde
            ];
          };

        tokyo =
          let system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            specialArgs = {
              hostname = "tokyo";
              type = "laptop";
              inherit system username;
            } // attrs;
            modules = [
              # import default modules through default.nix
              ./.
              # Specify host specific modules
              ./modules/hardware/network
              ./modules/desktop/kde
            ];
          };

        rapanui =
          let system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            specialArgs = {
              hostname = "rapanui";
              type = "laptop";
              inherit system username;
            } // attrs;
            modules = [
              # import default modules through default.nix
              ./.
              # Specify host specific modules
              ./modules/hardware/network
              ./modules/desktop/kde
            ];
          };

      }; # nixosConfigurations

      packages.x86_64-linux = {
        iso = nixos-generators.nixosGenerate {
            specialArgs = {
              system = "x86_64-linux";
              format = "install-iso";
              hostname = "live";
              type = "laptop"; # TODO this makes no sense
              inherit username;
            } // attrs;
          modules = [
            ./hosts
          ];
          system = "x86_64-linux";
          format = "install-iso";
        };

      }; # packages

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixpkgs-fmt
              statix
            ];
          };
        });

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      # templates.default = {
      #   path = ./.;
      #   description = "The default template for Eriim's nixflakes.";
      # }; #templates
    };
}
