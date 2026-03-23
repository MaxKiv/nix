{
  self,
  pkgs,
  ...
}: {
  # Enable ZFS support
  boot.zfs.enabled = true;

  # Optional: Enable ZFS scrubbing (recommended for data integrity)
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly"; # or "monthly"

  # Ensure the necessary tools are available in the environment
  environment.systemPackages = with pkgs; [
    zfs
  ];
}
