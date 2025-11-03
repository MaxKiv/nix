{
  pkgs,
  config,
  home-manager,
  inputs,
  ...
}: {
  imports = [
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [inputs.plasma-manager.homeModules.plasma-manager];
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    }

    ./hardware-configuration.nix
  ];
}
