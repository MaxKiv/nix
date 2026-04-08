{
  pkgs,
  username,
  ...
}: let
  server = "100.91.14.3";
  dataDir = "/data";
in {
  # Install NFS utilities
  environment.systemPackages = with pkgs; [
    nfs-utils # NFS client and server utilities
    rpcbind # RPC port mapper
  ];

  # make sure the mount dir exists
  systemd.tmpfiles.rules = [
    "d /mnt/nas/nfs 0755 root root -"
  ];

  systemd.mounts = [
    {
      what = "${server}:${dataDir}";
      where = "/mnt/nas/nfs";
      type = "nfs";
      options = "noatime,nfsvers=4";
    }
  ];

  systemd.automounts = [
    {
      wantedBy = ["multi-user.target"];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
      where = "/mnt/nas/nfs";
    }
  ];

  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = ["nfs"];
}
