{
  self,
  pkgs,
  username,
  ...
}: {
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly"; # or "monthly"

  environment.systemPackages = with pkgs; [
    zfs
    httm # browse snapshots
  ];

  # Make sure the default user is able to touch data on the slow pool
  users.users.${username} = {
    extraGroups = ["data"];
  };

  # Set appropriate ACL default on the /data dirs
  system.activationScripts.dataPermissions.text = ''
    for dir in /data/books /data/documents /data/movies /data/music /data/photos /data/series /data/audiobooks /data/youtube /data/downloads; do
      chmod g+s "$dir"
      ${pkgs.acl}/bin/setfacl -R -d -m u::rwx,g::rwx,o::rwx "$dir"
    done
  '';

  boot = {
    zfs.extraPools = ["slow"]; # fast is imported automatically as it contains root
    supportedFilesystems = ["zfs"];
    kernelPackages = pkgs.linuxPackages_6_18; # Latest LTS -> https://en.wikipedia.org/wiki/Linux_kernel_version_history
    zfs.package = pkgs.zfs_2_4; # Compatible with 6.18 kernel -> https://github.com/openzfs/zfs/releases
  };

  # Storage optimization for ZFS
  boot.kernel.sysctl = {
    # What it does: Tells the kernel to avoid swapping data out to the swap partition as much as possible. The default is usually 60.
    # Why for ZFS: ZFS relies heavily on RAM for its ARC (Adaptive Replacement Cache).
    # If the kernel starts swapping out ZFS metadata or data to disk because it thinks RAM is "free," performance tanks.
    # Setting this to 10 tells the kernel: "Only swap if absolutely necessary; keep everything else in RAM."
    "vm.swappiness" = 10;

    # What they do: These control how much dirty (modified but not yet written to disk) data can sit in RAM before the kernel forces a write.
    #     dirty_background_ratio: When the background write-back thread kicks in (starts flushing data to disk).
    #     dirty_ratio: The hard limit. If reached, all write operations by applications pause until data is flushed.
    # Why for ZFS: ZFS handles its own write caching (via the ZIL/SLOG and L2ARC).
    # If the Linux kernel buffers too much data in RAM before handing it to ZFS, it can cause "jitter" or latency spikes when the kernel finally forces a massive flush.
    # Lowering these ratios (to 5% and 15%) ensures data is passed to ZFS more frequently and steadily,
    # smoothing out I/O and preventing the system from freezing during heavy writes.
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;

    # What they do: These increase the limits on how many files the system can "watch" for changes (inotify) and the total number of open file handles.
    # Why for ZFS:
    #     Desktop/Dev Use: If you run IDEs (VS Code, IntelliJ), file sync tools (Syncthing, Dropbox), or media servers (Plex/Jellyfin), they watch thousands of files.
    #     The default Linux limit (often 8192 watches) is easily exhausted, causing errors like ENOSPC.
    #     ZFS Snapshots/Clones: ZFS operations involving many small files can also trigger these limits.
    #     Increasing them prevents "Too many open files" errors.
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 8192;
    "fs.file-max" = 2097152;
  };

  networking.hostId = "dd78583a";

  # fileSystems."/nix" = {
  #   device = "fast/nix";
  #   fsType = "zfs";
  # };
  #
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b42df4a87-part1";
  #   fsType = "vfat";
  # };

  # ZFS event daemon for monitoring
  services.zfs.zed = {
    settings = {
      ZED_DEBUG_LOG = "/var/log/zed.debug.log";
      # ZED_EMAIL_ADDR = ""; # Configure for alerts
      ZED_NOTIFY_VERBOSE = true;
    };
  };

  # SMART monitoring for disk health
  services.smartd = {
    enable = true;
    defaults.monitored = ''
      -a -o on -S on -n standby,q -s (S/../.././02|L/../../6/03) -W 4,35,40
    '';
  };
}
