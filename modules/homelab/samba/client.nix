{...}: {
  # FSTAB entry for the nas SMB share
  fileSystems."/mnt/nas/smb" = {
    device = "//192.168.1.10/data";
    fsType = "cifs";
    options = [
      "guest"
      "uid=1000" # max's uid
      "gid=1000" # max's gid
      "file_mode=0775"
      "dir_mode=0775"
      "vers=3.1.1"
      "_netdev" # wait for network before mounting
      "nofail" # don't halt boot if unreachable
      "x-systemd.automount" # mount on first access
      "x-systemd.mount-timeout=10s" # give up quickly if nas unreachable
    ];
  };
}
