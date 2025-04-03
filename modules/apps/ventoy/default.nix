{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ventoy-full
  ];
}
