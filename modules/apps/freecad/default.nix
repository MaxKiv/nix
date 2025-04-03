{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    freecad
  ];
}
