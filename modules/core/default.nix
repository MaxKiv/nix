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
    ++ lib.optionals (role != "server") [
      ./fonts
      ./pkgs
    ];
}
