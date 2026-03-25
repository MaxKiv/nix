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

      # Daily snapshots only for bulk media. It barely changes, hourly is wasteful
      "slow/media" = {
        useTemplate = ["media"];
        recursive = true;
      };

      "slow/photos" = {
        useTemplate = ["media"];
        recursive = false;
      };

      "slow/books" = {
        useTemplate = ["media"];
        recursive = false;
      };

      "slow/nextcloud" = {
        useTemplate = ["service"];
        recursive = false;
      };
    };

    templates = {
      service = {
        hourly = 24; # keep 24 hourly snapshots
        daily = 7; # keep 7 daily snapshots
        weekly = 4; # keep 4 weekly snapshots
        monthly = 3; # keep 3 monthly snapshots
        autosnap = true;
        autoprune = true;
      };

      media = {
        hourly = 0; # no hourlies — media doesn't change that fast
        daily = 7;
        weekly = 4;
        monthly = 2;
        autosnap = true;
        autoprune = true;
      };
    };
  };

  # Syncoid handles zfs send replication to an offsite backup.
  # services.syncoid = {
  #   enable = true;
  #   commands = {
  #     "fast/services" = {
  #       target = "user@backup-host:tank/nas-services";
  #       recursive = true;
  #       extraArgs = ["--compressed"];
  #     };
  #   };
  # };
}
