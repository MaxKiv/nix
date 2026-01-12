{
  hostname,
  username,
  config,
  lib,
  ...
}:
with lib; let
  tailCfg = config.my.networking.tailscale;
in {
  options.my.networking.tailscale.enable = mkEnableOption "Enable tailscale on this device";

  options.my.networking.tailscale.nodeType = mkOption {
    type = types.enum ["client" "server"];
    default = "client";
    description = ''
      Choose what tailscale node type this device is, either "client" or "server"
    '';
  };

  config = mkIf tailCfg.enable {
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

      useRoutingFeatures = tailCfg.nodeType;
      # Let clients handle their own DNS, required for clients to stay connected when tailscale down
      # accept-routes required for bad eduroam/corpo dnssec
      extraSetFlags = mkIf (tailCfg.nodeType == "client") [
        "--accept-dns=false"
        "--accept-routes=false"
      ];
    };

    networking.nameservers = mkIf (tailCfg.nodeType == "server") (mkForce [
      "100.100.100.100" # Tailscale DNS
      "1.1.1.1" # Cloudflare
      "8.8.8.8" # Doogle
    ]);

    services.resolved = mkIf (tailCfg.nodeType == "client") {
      enable = true;
      dnssec = "false";  # Works with "allow-downgrade" on all but Eduroam
      dnsovertls = "false"; # Works with "opportunistic" on all but Eduroam
      # domains = ["~."];
      fallbackDns = []; # do NOT override DHCP
      # fallbackDns = config.networking.nameservers;
    };

    networking.firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [config.services.tailscale.interfaceName];
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };
}
