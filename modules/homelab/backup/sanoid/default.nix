# Sanoid is a snapshot policy daemon.
# it creates snapshots on a schedule and prunes old ones according to retention rules.
{...}: {
  services.sanoid = {
    enable = true;

    datasets = {
      # Hourly snapshots, keep a week's worth. For fast-changing service state
      "fast/services/adguard" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/bazarr" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/calibre-web" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/gitea" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/hass" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/immich" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/jellyfin" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/jellyseerr" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/lidarr" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/mealie" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/postgresql" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/prowlarr" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/qbittorrent" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/radarr" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/readarr" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/sonarr" = {
        useTemplate = ["service"];
        recursive = true;
      };
      "fast/services/vaultwarden" = {
        useTemplate = ["service"];
        recursive = true;
      };

      "slow/data/books" = {
        useTemplate = ["media"];
        recursive = false;
      };

      "slow/data/documents" = {
        useTemplate = ["media"];
        recursive = false;
      };

      "slow/data/movies" = {
        useTemplate = ["media"];
        recursive = false;
      };

      "slow/data/music" = {
        useTemplate = ["media"];
        recursive = false;
      };

      "slow/data/nextcloud" = {
        useTemplate = ["media"];
        recursive = false;
      };
    };

    templates = {
      service = {
        hourly = 24; # keep 24 hourly snapshots
        daily = 7; # keep 7 daily snapshots
        weekly = 4; # keep 4 weekly snapshots
        monthly = 3; # keep 3 monthly snapshots
        yearly = 2;
        autosnap = true;
        autoprune = true;
      };

      media = {
        hourly = 1;
        daily = 7;
        weekly = 4;
        monthly = 12;
        yearly = 2;
        autosnap = true;
        autoprune = true;
      };
    };
  };
}
