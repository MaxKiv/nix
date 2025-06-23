{
  home-manager,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    # TODO: with this the nixpkgs overlays are visible to nixosConfigurations
    # Find a way to put this in the main overlay section of flake.nix
    inputs.dolphin-overlay.overlays.default
    inputs.niri.overlays.niri
  ];

  imports = [
    # HM import and settings
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [
        inputs.plasma-manager.homeManagerModules.plasma-manager
      ];
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    }
    ./assets
    ./hosts
    ./modules
    ./users
  ];
}
