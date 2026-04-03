# Sanoid is a snapshot policy daemon.
# it creates snapshots on a schedule and prunes old ones according to retention rules.
{...}: {
  services.sanoid = {
    enable = true;

    datasets = {
      # Hourly snapshots, keep a week's worth. For fast-changing service state
      "fast/services" = {
        useTemplate = ["service"];
        recursive = true; # applies to all children: gitea, postgres, vaultwarden, etc.
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
