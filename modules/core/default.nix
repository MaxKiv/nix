{
  lib,
  role,
  ...
}: {
  imports =
    [
      ./boot
      ./locale
      ./man
      ./nix
      ./ssh
      ./security
      ./terminal
      ./powerManager
      ./xdg
      ./earlyoom
    ]
    ++ lib.optional (role != "server") [
      ./fonts
      ./pkgs
    ];
}
