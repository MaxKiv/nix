{
  username,
  lib,
  sshKeys,
  pkgs,
  config,
  ...
}: let
  port = 8083;
  fqdn = "read.demtah.top";
in {
  services.calibre-web = {
    enable = true;
    user = "calibre";
    group = "data";
    listen.port = port;
    listen.ip = "127.0.0.1";
    options.enableBookUploading = true;
    options.calibreLibrary = "/data/books";
  };

  users.users.calibre = {
    isSystemUser = true;
    group = "data";
  };

  services.nginx = {
    virtualHosts = {
      "${fqdn}" = {
        default = false;
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
        };
      };
    };
  };

  security.acme.certs."${fqdn}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };
}
