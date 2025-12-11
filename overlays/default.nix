# shamelessly stolen from https://github.com/Sileanth/nixosik/blob/63354cf060e9ba895ccde81fd6ccb668b7afcfc5/overlays/default.nix
# This file defines overlays
{inputs, ...}: {
  # Adds custom packages
  additions = final: _prev: import ../pkgs final inputs;

  # Modifies existing packages
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    sway-displaylink = let
      wlroots-sway = prev.wlroots.overrideAttrs (_: {
        # https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/4824
        patches = [
          (prev.fetchpatch {
            name = "scannout-without-mgpu-renderer.patch";
            url = "https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/4824.patch";
            sha256 = "19phmcplc1y2rvhvgi6a2vkzflkf9b2xzlyb58dvbffl87vgv224";
          })
        ];
      });

      sway-unwrapped = prev.sway-unwrapped.override {
        wlroots = wlroots-sway;
      };
    in
      prev.sway.override {
        inherit sway-unwrapped;
        extraOptions = ["--unsupported-gpu"];
      };
  };

  # # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # # be accessible through 'pkgs.unstable'
  # unstable-packages = final: _prev: {
  #   unstable = import inputs.nixpkgs-unstable {
  #     system = final.system;
  #     config.allowUnfree = true;
  #   };
  # };
}
