{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kicad
  ];
}
