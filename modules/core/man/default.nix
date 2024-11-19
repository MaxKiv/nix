{
  inputs,
  home-manager,
  pkgs,
  username,
  ...
}: {
  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    tldr # simpler man with examples
  ];
}
