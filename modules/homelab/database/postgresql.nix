{config, ...}: {
  # Declare postgres yourself
  services.postgresql = {
    enable = true;
    # Explicitly set datadir to default on fast zfs dataset
    dataDir = "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
  };
}
