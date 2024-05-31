# shamelessly stolen from https://github.com/Sileanth/nixosik/blob/63354cf060e9ba895ccde81fd6ccb668b7afcfc5/overlays/default.nix
# This file defines overlays
{inputs, ...}: {

  # This one brings our custom packages from the 'pkgs' directory
  # additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  nvim-nightly = inputs.neovim-nightly-overlay.overlays.default;

  # # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # # be accessible through 'pkgs.unstable'
  # unstable-packages = final: _prev: {
  #   unstable = import inputs.nixpkgs-unstable {
  #     system = final.system;
  #     config.allowUnfree = true;
  #   };
  # };

}
