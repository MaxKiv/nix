{
  self,
  config,
  ...
}: let
  restic-sops-file = self + "/secrets/restic.env";
in {
  sops.secrets = {
    restic-env = {
      sopsFile = restic-sops-file;
      format = "dotenv";
    };

    "restic/pass" = {};
    "restic/ssh_key" = {};
  };

  # Restic: ship syncoid synced snapshots to offsite NAS
  services.restic.backups = {
    offsite = {
      initialize = true; # creates the restic repo on first run if it doesn't exist

      # Read from the local backup datasets, not the live service paths
      paths = [
        # Datasets of fast pool on the slow hdds, replicated by syncoid
        "/backup/local/services/adguard"
        "/backup/local/services/calibre-web"
        "/backup/local/services/gitea"
        "/backup/local/services/postgresql"
        "/backup/local/services/hass"
        "/backup/local/services/immich"
        "/backup/local/services/jellyfin"
        "/backup/local/services/mealie"
        "/backup/local/services/vaultwarden"

        # Slow pool datasets
        "/data/books"
        "/data/documents"
        # "/data/movies" # easily replaced
        "/data/music"
        "/data/nextcloud"
        "/data/photos"
      ];

      # This env file defines the restic offsite repo, password and sftp command
      environmentFile = config.sops.secrets.restic-env.path;
      passwordFile = config.sops.secrets."restic/pass".path;

      extraOptions = [
        "sftp.command='ssh -p 31502 -i ${config.sops.secrets."restic/ssh_key".path} -o StrictHostKeyChecking=yes max@100.112.182.124 -s sftp'"
      ];

      # Make sure this is after syncoid runs!
      timerConfig = {
        OnCalendar = "05:00";
        Persistent = true; # If we missed the window (maybe nas died or w/e), make sure to trigger restic at the earliest possibility
        RandomizedDelaySec = "30m";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
      ];
    };
  };

  # Acknowledge offsite SSH key
  programs.ssh.knownHosts.offsite = {
    hostNames = ["100.112.182.124"];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9W+djwKZT5DbPLEotrQ4xBENQOP4NDKYz75UV0HHb+";
  };
}
