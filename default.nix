{ home-manager
, inputs
, ...
}: {
  imports = [
    # HM import and settings
    home-manager.nixosModules.home-manager
    {
      nixpkgs.overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = { inherit inputs; };
    }
    ./assets
    ./hosts
    ./modules
    ./users
  ];
}
