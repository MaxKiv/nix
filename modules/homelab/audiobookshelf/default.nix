{
  config,
  username,
  lib,
  sshKeys,
  pkgs,
  ...
}: let
  port = 8000;
  fqdn = "listen.demtah.top";
in {
  services.audiobookshelf = {
    enable = true;
    port = port;
    host = "0.0.0.0";
    openFirewall = false;
    user = "audiobook";
    group = "data";
    dataDir = "/data/audiobooks";
  };

  users.users.audiobook = {
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
