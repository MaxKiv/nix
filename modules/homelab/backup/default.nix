{config, ...}: {
  imports = [
    ./sanoid
    ./syncoid
    ./restic
  ];

  # Additional configuration if "perfect snapshots are required"
  # Just using sanoid gives "crash consistency", i.e. I might lose the writes that were just happening when the zfs snapshot was taken
  # This seems fine for now, especially since I snapshot once an hour at most anyway, so the missed data from that is potentially much bigger
  # NOTE: enable these when perfect snapshots are something you want, make sure to integrate it into syncoid/restic above
  # Back up postgresql
  # services.postgresqlBackup = {
  #   enable = true;
  #   databases = ["git"];
  #   location = "/var/backup/postgresql";
  #   startAt = "02:00"; # systemd calendar format
  #   compression = "zstd";
  # };

  # Back up mysql
  # services.mysqlBackup = {
  #   enable = true;
  #   databases = ["mydb"];
  #   location = "/var/backup/mysql";
  #   startAt = "02:00";
  # };

  # Back up sqlite
  # services.restic.backups.databases = {
  #   backupPrepareCommand = ''
  #     sqlite3 /var/lib/myapp/data.sqlite ".backup /var/backup/sqlite/myapp.sqlite"
  #   '';
  #   # ...
  # };
}
