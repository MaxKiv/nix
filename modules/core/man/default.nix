{
  inputs,
  home-manager,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = [pkgs.man-pages pkgs.man-pages-posix];
  documentation.dev.enable = true;
}
