{pkgs, ...}: {
  environment.systemPackages = with pkgs; [wireguard-tools proton-vpn];
}
