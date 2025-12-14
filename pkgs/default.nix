# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  displaylink = pkgs.callPackage ./displaylink.nix {};

  clipvault = pkgs.callPackage ./clipvault.nix {};
}
