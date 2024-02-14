{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";

    home-manager = {
      url = "github:rycee/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:maxkiv/nix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      nixosConfigurations.uptown = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/uptown/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/laptop/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

      nixosConfigurations.downtown = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/downtown/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

      nixosConfigurations.live = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs; };

          modules = [
        (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./hosts/default/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };


    };
}
