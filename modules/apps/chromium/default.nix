{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    chromium
  ];
}
