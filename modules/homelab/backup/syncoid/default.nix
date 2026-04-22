{...}: {
  # Syncoid handles zfs snapshot replication, possibly to offsite zfs system
  # In this case we replicate snapshots of the fast nvme pool to the slow raidz2 pool to prevent data loss in case the single nvme dies
  services.syncoid = {
    enable = true;
    user = "root"; # Local replication anyway

    # Run as root so it can read all datasets without ZFS delegation complexity
    # For local-only replication this is acceptable
    commands = {
      "fast/services" = {
        source = "fast/services";
        target = "slow/backup/local/services";
        recursive = true;
        extraArgs = [
          "--no-privilege-elevation"
          "--skip-parent"
          "--exclude=fast/services/downloads"
          "--exclude=fast/services/downloads/.incomplete"
        ];
        localTargetAllow = [
          "change-key"
          "compression"
          "create"
          "mount"
          "mountpoint"
          "receive"
          "rollback"
          "destroy"
        ];
      };
    };
    # Run after sanoid has had a chance to snapshot
    # Sanoid runs on its own timer; stagger syncoid slightly after
    interval = "*-*-* 04:30:00"; # nightly at 4:30am
  };
}
