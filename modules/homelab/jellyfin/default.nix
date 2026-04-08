{config, ...}: let
  storageDirHDD = "/data/media";
  dataDirSSD = "/var/lib";
  domain = "demtah.top";

  jellyfinHostname = "jellyfin";
  jellyfinPort = 8096; # default
  jellyfin_fqdn = "${jellyfinHostname}.${domain}";

  seerHostname = "seer";
  seerPort = 5055; # default
  seer_fqdn = "${seerHostname}.${domain}";
in {
  users.users.media = {
    isSystemUser = true;
    group = "data";
  };

  # Media Request Manager. Overseerr fork for jellyfin
  services.jellyseerr = {
    enable = true;
    port = seerPort;
    configDir = "${dataDirSSD}/jellyseerr/config";
  };

  # Self hosted media player
  services.jellyfin = rec {
    enable = true;
    user = "media";
    group = "data";
    dataDir = "${dataDirSSD}/jellyfin";
    cacheDir = "${dataDir}/cache";
    configDir = "${dataDir}/config";
  };

  services.nginx = {
    virtualHosts = {
      "${jellyfin_fqdn}" = {
        default = false;
        forceSSL = true;
        useACMEHost = jellyfin_fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString jellyfinPort}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;  # important for streaming
          '';
        };
      };

      "${seer_fqdn}" = {
        default = false;
        forceSSL = true;
        useACMEHost = seer_fqdn;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${toString seerPort}";
        };
      };
    };
  };

  security.acme.certs = let
    acmeSettings = {
      dnsProvider = "acme-dns";
      environmentFile = config.sops.secrets.acme-dns-env.path;
    };
  in {
    "${jellyfin_fqdn}" = acmeSettings;
    "${seer_fqdn}" = acmeSettings;
  };
}
