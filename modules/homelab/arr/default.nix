# https://github.com/rwiankowski/homeserver-nixos/blob/main/modules/arr-stack.nix
{
  username,
  config,
  pkgs,
  ...
}: let
  storageDirHDD = "/data";
  dataDirSSD = "/var/lib";
  domain = "demtah.top";

  qbitHostname = "qbit";
  qbitWebUIPort = 8282;
  qbit_fqdn = "${qbitHostname}.${domain}";

  radarrHostname = "radarr";
  radarr_fqdn = "${radarrHostname}.${domain}";
  radarrWebUIPort = 7878;

  bazarrHostname = "bazarr";
  bazarr_fqdn = "${bazarrHostname}.${domain}";
  bazarrWebUIPort = 6767;

  sonarrWebUIPort = 8989;
  sonarrHostname = "sonarr";
  sonarr_fqdn = "${sonarrHostname}.${domain}";

  readarrWebUIPort = 8787;
  readarrHostname = "readarr";
  readarr_fqdn = "${readarrHostname}.${domain}";

  prowlarrWebUIPort = 9696;
  prowlarrHostname = "prowlarr";
  prowlarr_fqdn = "${prowlarrHostname}.${domain}";

  lidarrWebUIPort = 8686;
  lidarrHostname = "lidarr";
  lidarr_fqdn = "${lidarrHostname}.${domain}";

  flaresolverrWebUIPort = 8191;
  flaresolverrHostname = "flaresolverr";
  flaresolverr_fqdn = "${flaresolverrHostname}.${domain}";
in {
  users.users.media = {
    isSystemUser = true;
    group = "data";
  };

  # TV show manager
  services.sonarr = {
    enable = true;
    openFirewall = false;
    user = "media";
    group = "data";
    dataDir = "${dataDirSSD}/sonarr";
    settings.server = {
      port = sonarrWebUIPort;
      # urlbase = "localhost";
      # bindaddress = "*";
    };
  };

  # Movie manager
  services.radarr = {
    enable = true;
    openFirewall = false;
    user = "media";
    group = "data";
    dataDir = "${dataDirSSD}/radarr";
    settings.server.port = radarrWebUIPort;
  };

  # Torrent tracker & Usenet indexer management
  services.prowlarr = {
    enable = true;
    openFirewall = false;
    # Note: Prowlarr in NixOS 25.05 does not support custom dataDir
    # Data will be stored in /var/lib/prowlarr (managed by StateDirectory)
  };

  # An indexer proxy to handle Cloudflare challenges
  services.flaresolverr = {
    enable = true;
    openFirewall = false;
    port = 8191;
  };

  # Subtitle management
  services.bazarr = {
    enable = true;
    openFirewall = false;
    user = "media";
    group = "data";
    listenPort = bazarrWebUIPort;
    # Note: Bazarr in NixOS 25.05 does not support custom dataDir
    # Data will be stored in /var/lib/bazarr (managed by StateDirectory)
  };

  # Ebook manager
  services.readarr = {
    enable = true;
    openFirewall = false;
    user = "media";
    group = "data";
    dataDir = "${dataDirSSD}/readarr";
    settings.server.port = readarrWebUIPort;
  };

  # Music manager
  services.lidarr = {
    enable = true;
    openFirewall = false;
    user = "media";
    group = "data";
    dataDir = "${dataDirSSD}/lidarr";
    settings.server.port = lidarrWebUIPort;
  };

  # Torrent client user
  users.users.qbit = {
    isSystemUser = true;
    group = "data";
  };
  # Torrent client
  services.qbittorrent = {
    enable = true;
    openFirewall = false;
    user = "qbit";
    group = "data";
    profileDir = "${dataDirSSD}/qbittorrent";
    webuiPort = qbitWebUIPort;

    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        Downloads = {
          SavePath = "${storageDirHDD}/downloads";
          TempPath = "${dataDirSSD}/downloads/.incomplete";
          TempPathEnabled = true;
        };
        WebUI = {
          # Allow access from reverse proxy
          CSRFProtection = false;
          HostHeaderValidation = false;
          Username = "${username}";
          Password_PBKDF2 = "@ByteArray(tv7rYRNvB59WgQV4yX0RKg==:8nr0Jxso/K2Us/XSm8vBzQjL2Wj2Pci5jGwgAIDuP/h6ueoqPFub+CmgEYaWE25BKNRb6OPFgFeBf1YkubzDdg==)"; # pbkdf2 hash
        };
      };
    };
  };

  services.nginx = {
    virtualHosts = let
      virtualHostSettings = {
        fqdn,
        port,
      }: {
        default = false;
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
        };
      };
    in {
      "${qbit_fqdn}" = {
        default = false;
        forceSSL = true;
        useACMEHost = qbit_fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString qbitWebUIPort}";
          proxyWebsockets = true; # qBittorrent uses websockets for the UI
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-Host $http_host;
          '';
        };
      };

      "${sonarr_fqdn}" = virtualHostSettings {
        fqdn = sonarr_fqdn;
        port = sonarrWebUIPort;
      };

      "${radarr_fqdn}" = virtualHostSettings {
        fqdn = radarr_fqdn;
        port = radarrWebUIPort;
      };

      "${bazarr_fqdn}" = virtualHostSettings {
        fqdn = bazarr_fqdn;
        port = bazarrWebUIPort;
      };

      "${prowlarr_fqdn}" = virtualHostSettings {
        fqdn = prowlarr_fqdn;
        port = prowlarrWebUIPort;
      };

      "${readarr_fqdn}" = virtualHostSettings {
        fqdn = readarr_fqdn;
        port = readarrWebUIPort;
      };

      "${lidarr_fqdn}" = virtualHostSettings {
        fqdn = lidarr_fqdn;
        port = lidarrWebUIPort;
      };

      "${flaresolverr_fqdn}" = virtualHostSettings {
        fqdn = flaresolverr_fqdn;
        port = flaresolverrWebUIPort;
      };
    };
  };

  security.acme.certs = let
    acmeSettings = {
      dnsProvider = "acme-dns";
      environmentFile = config.sops.secrets.acme-dns-env.path;
    };
  in {
    "${qbit_fqdn}" = acmeSettings;
    "${sonarr_fqdn}" = acmeSettings;
    "${bazarr_fqdn}" = acmeSettings;
    "${radarr_fqdn}" = acmeSettings;
    "${readarr_fqdn}" = acmeSettings;
    "${lidarr_fqdn}" = acmeSettings;
    "${prowlarr_fqdn}" = acmeSettings;
    "${flaresolverr_fqdn}" = acmeSettings;
  };
}
