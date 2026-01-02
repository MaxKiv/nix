{
  username,
  config,
  lib,
  ...
}: {
  sops.secrets = {
    "tailscale-auth-keyfile" = {
      # neededForUsers = true;
    };
  };

  services.tailscale = {
    enable = true;
    # If the tailscale key is out of date regenerate one via
    # https://login.tailscale.com/admin/machines
    authKeyFile = config.sops.secrets.tailscale-auth-keyfile.path;
    interfaceName = "tailscale0";
    # port = 41641;
    openFirewall = true;
    extraDaemonFlags = [
      "-no-logs-no-support"
    ];
    useRoutingFeatures = "client";
    # Let me handle DNS, required for clients to stay connected when tailscale down
    extraUpFlags = [
      "--accept-dns=false"
    ];
  };

  # networking.nameservers = lib.mkForce [
  #   "100.100.100.100"
  #   "1.1.1.1" # Cloudflare
  #   "8.8.8.8" # Doogle
  # ];

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    dnsovertls = "opportunistic";
    domains = ["~."];
    fallbackDns = config.networking.nameservers;
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    trustedInterfaces = [config.services.tailscale.interfaceName];
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
