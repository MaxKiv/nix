{
  username,
  lib,
  sshKeys,
  pkgs,
  ...
}: let
  port = 8499;
  fqdn = "yt.demtah.top";
in {
  services.pinchflat = {
    enable = true;
    port = port;
    user = "pinchflat";
    group = "data";
    dataDir = "/data/youtube";
  };

  services.nginx = {
    virtualHosts = {
      "${fqdn}" = {
        default = false;
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
        };
      };
    };
  };

  security.acme.certs."${fqdn}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };
}
