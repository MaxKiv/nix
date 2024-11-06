{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    deluge
  ];
}
