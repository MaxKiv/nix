{
  config,
  pkgs,
  ...
}: let
  domain = "demtah.top";
  hostname = "photo";
  fqdn = "${hostname}.${domain}";
  privatePort = 2282;
  immichUser = "immich";
in {
  services.immich = {
    enable = true;
    port = privatePort;
    user = immichUser;

    # dataDir = "/var/lib/immich";

    host = "127.0.0.1"; # Listen on localhost only, nginx will proxy

    # Immich media storage location on ZFS, stores media uploaded via immich
    # Note: photo dir will be marked as external source, immich indexes this but doesn't take ownership
    mediaLocation = "/data/photos/immich";

    # Enable built-in PostgreSQL "immich" with required extensions (pgvector, vectorChord)
    # Also does a bunch of plumbing
    database = {
      enable = true;
      createDB = true;
    };

    # Enable built-in Redis
    redis.enable = true;

    # Machine learning for face detection and smart search
    # Note: Try this later
    machine-learning.enable = false;

    # Configuration settings
    # Note: Setting to null allows web UI configuration
    # Configuration for Immich. See https://immich.app/docs/install/config-file/
    # or navigate to https://my.immich.app/admin/system-settings for options and defaults.
    # Setting it to null allows configuring Immich in the web interface.
    # You can load secret values from a file in this configuration by setting somevalue._secret = "/path/to/file" instead of setting somevalue directly.
    settings = null;

    # Enable hardware accelerated video transcoding
    accelerationDevices = null;
  };

  services.nginx = {
    virtualHosts = {
      "${fqdn}" = {
        default = false;
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString privatePort}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            # Large file upload support for photos/videos
            client_max_body_size 50000M;

            # Extended timeouts for large file uploads
            proxy_connect_timeout 60s;
            proxy_send_timeout 600s;
            proxy_read_timeout 600s;
            send_timeout 600s;
          '';
        };
      };
    };
  };

  security.acme.certs."${fqdn}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };

  # Enable hardware accelerated video transcoding
  users.users.immich.extraGroups = ["video" "render"];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      # intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
    ];
  };
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Optionally, set the environment variable
}
