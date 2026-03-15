{
  pkgs,
  username,
  ...
}: let
  mountUser = username;
  server = "downtown.local";
  dataDir = "/nas/data";
in {
  # Install NFS utilities
  environment.systemPackages = with pkgs; [
    nfs-utils # NFS client and server utilities
    rpcbind # RPC port mapper
  ];

  # Working manual command:
  # mount -t cifs //192.168.1.2/data /mnt/nas -o vers=3.1.1,guest,uid=$(id -u max),gid=$(id -g max),file_mode=0775,dir_mode=0775

  # make sure the mount dir exists
  systemd.tmpfiles.rules = [
    "d /mnt/nas 0755 root root -"
  ];

  systemd.mounts = [
    {
      what = "${server}:${dataDir}";
      where = "/mnt/nas";
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
      where = "/mnt/nas";
    }
  ];

  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = ["nfs"];
}
