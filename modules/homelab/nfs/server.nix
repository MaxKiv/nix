{
  pkgs,
  username,
  ...
}: {
  # Install NFS utilities
  environment.systemPackages = with pkgs; [
    nfs-utils # NFS client and server utilities
    rpcbind # RPC port mapper
  ];

  services.nfs.server = {
    enable = true;
    # fixed rpc.statd port; for firewall
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    extraNfsdConfig = '''';

    # NFS share configs
    exports = ''
      /nas/data 192.168.1.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1001,anongid=982)
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [
      111 # RPC portmapper
      2049 # NFS daemon
      4000 # NFSv4 callback
      4001 # NFS lock manager
      4002 # NFS status monitor
    ];
    allowedUDPPorts = [
      111 # RPC portmapper
      2049 # NFS daemon
      4000 # NFSv4 callback
      4001 # NFS lock manager
      4002 # NFS status monitor
    ];
  };

  users.users."nobody" = {
    extraGroups = ["nas"];
  };

  users.groups.nas = {
    gid = 982;
    members = [username "nas" "nobody"];
  };

  # Enable RPC services required for NFS
  services.rpcbind.enable = true;
}
