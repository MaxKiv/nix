{
  username,
  lib,
  sshKeys,
  pkgs,
  config,
  ...
}: let
  storageDirHDD = "/data";
  domain = "demtah.top";
  hostname = "pass";
  port = 8222;
  fqdn = "${hostname}.${domain}";
in {
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://${fqdn}";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = port;

      ROCKET_LOG = "critical";
    };
  };

  services.nginx.virtualHosts."${fqdn}" = {
    default = false;
    forceSSL = true;
    useACMEHost = fqdn;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
    };
  };

  security.acme.certs."${fqdn}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };
}
