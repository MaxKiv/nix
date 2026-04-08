{
  self,
  config,
  pkgs,
  sopsFile,
  ...
}: let
  sopsFile = self + "/secrets/protonvpn.conf.enc";
  wgSecretPath = "/etc/wireguard/protonvpn.conf";
in {
  # Allow WireGuard through firewall
  networking.firewall = {
    allowedUDPPorts = [51820];
    # Required for wg-quick's routing rules to work
    checkReversePath = false;
  };

  networking.wg-quick.interfaces.protonvpn = {
    configFile = wgSecretPath;
    autostart = true;
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools # gives you `wg` CLI for debugging
  ];

  # WireGuard Configuration
  sops.secrets.protonvpn = {
    inherit sopsFile;
    path = wgSecretPath;
    format = "binary";
    mode = "0400";
    owner = "root";
  };
}
