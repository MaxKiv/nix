{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mumble
  ];
}
