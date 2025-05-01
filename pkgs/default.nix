# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  final,
  inputs,
  ...
}: {
  neovim-nightly = inputs.neovim-nightly.packages.${final.system}.default;

  displaylink = final.pkgs.callPackage ./displaylink.nix {};
}
