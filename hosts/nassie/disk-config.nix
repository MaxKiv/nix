{username, ...}: {
  disko.devices = {
    disk = {
      nvme1 = {
        device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b42df4a87";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "4G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "fast";
              };
            };
          };
        };
      };

      # HDD ZFS pool
      hdd1 = {
        device = "/dev/disk/by-id/ata-HGST_HUS726T6TALE6L4_V7GA81XH";
        type = "disk";
        content = {
          type = "zfs";
          pool = "slow";
        };
      };
      hdd2 = {
        device = "/dev/disk/by-id/ata-HGST_HUS726T6TALE6L4_V7GADXDJ";
        type = "disk";
        content = {
          type = "zfs";
          pool = "slow";
        };
      };
      hdd3 = {
        device = "/dev/disk/by-id/ata-HGST_HUS726T6TALE6L4_V7GAGMDJ";
        type = "disk";
        content = {
          type = "zfs";
          pool = "slow";
        };
      };
      hdd4 = {
        device = "/dev/disk/by-id/ata-HGST_HUS726T6TALE6L4_V8GSKELR";
        type = "disk";
        content = {
          type = "zfs";
          pool = "slow";
        };
      };
      hdd5 = {
        device = "/dev/disk/by-id/ata-HGST_HUS726T6TALE6L4_V8GSWA5R";
        type = "disk";
        content = {
          type = "zfs";
          pool = "slow";
        };
      };
    };

    zpool = {
      # NVME pool
      fast = {
        type = "zpool";
        mode = ""; # Only a single drive

        # Fast ZFS Pool Properties
        # https://jrs-s.net/2018/08/17/zfs-tuning-cheat-sheet/
        options = {
          ashift = "12"; # 4K alignment, depends on disk sector size, almost always 4k
          autotrim = "on"; # Crucial for SSDs/NVMe, harmless for HDDs
          failmode = "continue"; # Default is "wait" which hangs the system on pool errors. "continue" returns errors to applications
          # cachefile = "none"; # Optional: Prevents stale cache issues in VMs/containers
        };

        # Fast "Root" dataset options, inherited but overridable by other datasets in this pool
        rootFsOptions = {
          compression = "zstd"; # fast pool has lots of service state -> highly compressable.
          atime = "off"; # Performance boost
          xattr = "sa"; # Performance for extended attributes
          acltype = "posixacl"; # Compatibility with Linux ACLs
          normalization = "formD"; # Unicode safety
          mountpoint = "none"; # Don't auto-mount the pool root
          canmount = "off"; # Prevent accidental mounting of the pool root
          dnodesize = "auto"; # Let ZFS pick a dnode size 1kb/512b
          # match the recordsize to the size of the reads or writes you’re going to be doing
          # 64k is on the higher end of the spectrum for default DB backends
          recordsize = "64k";
          "com.sun:auto-snapshot" = "false"; # Sanoid takes care of auto snapshots
        };

        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^fast@blank$' || zfs snapshot fast@blank";

        # -- fast pool --
        datasets = {
          "system" = {
            type = "zfs_fs";
          };

          "system/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
            };
          };

          "system/nix" = {
            type = "zfs_fs";
            options = {
              reservation = "128M";
              mountpoint = "legacy";
            };
            mountpoint = "/nix";
          };

          "services" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              canmount = "off";
            };
          };

          "services/postgresql" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/postgresql";
              recordsize = "8K"; # matches default 8k postgres page size
              logbias = "latency";
              sync = "standard";
              reservation = "10G"; # postgres always has space even if pool fills
            };
          };

          "services/gitea" = {
            type = "zfs_fs";
            options.mountpoint = "/var/lib/gitea";
          };

          "services/hass" = {
            type = "zfs_fs";
            options.mountpoint = "/var/lib/hass";
          };

          "services/adguard" = {
            type = "zfs_fs";
            options.mountpoint = "/var/lib/adguardhome";
          };

          "services/arr" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/arr";
              sync = "disabled"; # arr DBs are fully rebuildable — safe to skip fsync for speed
            };
          };

          "services/vaultwarden" = {
            type = "zfs_fs";
            options.mountpoint = "/var/lib/vaultwarden";
            # SQLite, small random writes
          };

          "services/immich" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/immich";
              # immich uses postgres for metadata, this holds the app state
            };
          };

          "services/calibre-web" = {
            type = "zfs_fs";
            options.mountpoint = "/var/lib/calibre-web";
          };

          "services/jellyfin" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/jellyfin";
              recordsize = "32K";
            };
          };

          "services/acme" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/acme";
            };
          };

          "mealie" = {
            type = "zfs_fs";
            options.mountpoint = "/var/lib/private/mealie";
          };
        };
      };

      # HDD pool
      slow = {
        type = "zpool";
        mode = "raidz2";

        # Slow ZFS Pool Properties
        # https://jrs-s.net/2018/08/17/zfs-tuning-cheat-sheet/
        options = {
          ashift = "12"; # 4K alignment, depends on disk sector size, almost always 4k
          autotrim = "off"; # Crucial for SSDs/NVMe, useless IO for HDDs
          failmode = "continue"; # Default is "wait" which hangs the system on pool errors. "continue" returns errors to applications
          # cachefile = "none"; # Optional: Prevents stale cache issues in VMs/containers
        };

        # Slow "Root" dataset options, inherited but overridable by other datasets in this pool
        rootFsOptions = {
          compression = "lz4"; # Most media files are highly compressed, lz4 wastes less cpu. TODO: find out if raw images make zstd worth it?
          atime = "off"; # Performance boost
          xattr = "sa"; # Performance for extended attributes
          acltype = "posixacl"; # Compatibility with Linux ACLs
          normalization = "formD"; # Unicode safety
          mountpoint = "none"; # Don't auto-mount the pool root
          canmount = "off"; # Prevent accidental mounting of the pool root
          dnodesize = "auto"; # Let ZFS pick a dnode size 1kb/512b
          recordsize = "1M";
          primarycache = "metadata"; # Primary cache = RAM, media files will never fit there so lets cache metadata
          # secondarycache = "all"; # Secondary L2ARC (ssd cache) config, enable if I end up with one
          "com.sun:auto-snapshot" = "false"; # Sanoid takes care of auto snapshots
        };

        datasets = {
          # -- slow pool --
          "data/movies" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/data/movies";
            };
          };

          "data/music" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/data/music";
            };
          };

          "data/nextcloud" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/data/nextcloud";
              recordsize = "128K"; # nextcloud chunks uploads at ~8MB, 128K is a good middle ground
              primarycache = "all"; # override slow pool default — nextcloud data is worth caching
              quota = "1T"; # Prevent nextcloud from filling the pool
            };
          };

          "data/photos" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/data/photos";
            };
          };

          "data/books" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/data/books";
              recordsize = "128K"; # epub/pdf, mixed sizes
            };
          };

          "data/documents" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/data/documents";
            };
          };

          "nfs" = {
            type = "zfs_fs";
            options.mountpoint = "/export";
          };
        };
      };
    };
  };

  users.groups.data = {};

  systemd.tmpfiles.rules = [
    "d /data/books     0775 root data - -"
    "d /data/documents 0775 root data - -"
    "d /data/movies    0775 root data - -"
    "d /data/music     0775 root data - -"
    "d /data/photos    0775 root data - -"
    "d /data/nextcloud 0775 root data - -"
  ];

  users.users.${username}.extraGroups = ["data"];
}
