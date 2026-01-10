{
  inputs,
  self,
}: {
  hostname,
  username ? "max",
  email ? "maxkivits42@gmail.com",
  system ? "x86_64-linux",
  modules ? [],
}: let
  pkgs = import inputs.nixpkgs {
    inherit system;

    config.allowUnfree = true;

    overlays = [
      self.overlays.default.modifications
      self.overlays.default.additions
      self.overlays.dolphin
    ];
  };

  sshKeys = import (self + "/lib/ssh.nix");
in
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs hostname username system self email sshKeys;
      inherit (inputs) home-manager;
    };

    modules =
      [
        # Global nixpkgs config
        {
          nixpkgs = {
            inherit pkgs;
            hostPlatform = system;
          };
        }

        # Base configuration
        ../hosts/${hostname}
        ../users
        ../modules

        # Home Manager
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {inherit inputs;};
            sharedModules = [
              inputs.plasma-manager.homeModules.plasma-manager
            ];
          };
        }
      ]
      ++ modules;
  }
