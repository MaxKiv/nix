{ home-manager, inputs, ... }:
{
  imports = [
    home-manager.nixosModules.home-manager
    {
      nixpkgs.overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
    }
    ./assets
    ./hosts
    ./modules
    ./users
  ];
}
