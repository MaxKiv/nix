{pkgs, ...}: let
  server = "downtown.local";
  dataDir = "/data";
in {
  # Install NFS utilities
  environment.systemPackages = with pkgs; [
    nfs-utils # NFS client and server utilities
    rpcbind # RPC port mapper
  ];

  fileSystems."/mnt/nas" = {
    device = "${server}:${dataDir}";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "rw"
      "noatime"
      "nodiratime"
      "nfsvers=4"
    ]; # lazy mount + disconnects after 10 minutes (i.e. 600 seconds)
  };
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = ["nfs"];
}
