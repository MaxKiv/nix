{pkgs, ...}: {
  environment.systemPackages = with pkgs; [wireguard-tools protonvpn-gui];
}
