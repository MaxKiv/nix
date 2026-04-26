{
  config,
  username,
  lib,
  sshKeys,
  pkgs,
  self,
  ...
}: let
  port = 8499;
  fqdn = "yt.demtah.top";
  sopsFile = self + "/secrets/pinchflat.env";
in {
  services.pinchflat = {
    enable = true;
    port = port;
    user = "pinchflat";
    group = "data";
    mediaDir = "/data/youtube";
    secretsFile = config.sops.secrets."pinchflat-env".path;
  };

  users.users.pinchflat = {
    isSystemUser = true;
    group = "data";
  };

  sops.secrets.pinchflat-env = {
    inherit sopsFile;
    owner = "pinchflat";
    group = "data";
    mode = "0400";
    format = "dotenv";
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
