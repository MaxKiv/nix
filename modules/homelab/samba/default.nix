{
  username,
  lib,
  sshKeys,
  ...
}: let
  sambaUser = "nas";
in {
  # Host Setup:
  # Set up sambaUser password: `sudo smbpasswd -a sam`
  # Check samba share directory permissions with `ls -ld /nas/data`, should be owned by ${sambaUser}
  # If not, change with `sudo chown -R ${sambaUser}:${sambaUser} /nas/data`
  #
  # Client Setup:
  # sudo mount -t cifs //192.168.1.2/data /mnt/nas -o vers=3.1.1,guest,uid=$(id -u max),gid=$(id -g max),file_mode=0775,dir_mode=0775
  # Make sure the clients user is part of the ${sambaUser} group
  #
  # Windows clients:
  # in explorer: \\${SambaHostIp}\data

  # Enable web service discovery daemon, should allow windows clients to find the samba share
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # Configure samba
  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        "server string" = "NAS Samba";
        "workgroup" = "WORKGROUP";

        # Security
        "security" = "user";
        "server min protocol" = "SMB2";
        "server max protocol" = "SMB3";

        # Authentication settings
        # "map to guest" = "never";
        # "guest account" = "nobody";
        "invalid users" = ["root"];

        # Performance & correctness
        "ea support" = "yes";
        "vfs objects" = "acl_xattr";
        "map acl inherit" = "yes";
        "store dos attributes" = "yes";
        # "socket options" = "TCP_NODELAY SO_RCVBUF=524288 SO_SNDBUF=524288";
        "use sendfile" = "yes";

        # Disable printing
        "load printers" = "no";
        printing = "bsd";
        "printcap name" = "/dev/null";
        "disable spoolss" = "yes";

        # Logging
        "log file" = "/var/log/samba/log.%m";
        "max log size" = "1000";
      };

      data = {
        path = "/nas/data";
        browseable = "yes";
        "guest ok" = "yes";
        "read only" = "no";
        "force user" = sambaUser;
        "force group" = sambaUser;
        "create mask" = "0664"; # New files: rw-rw-r--
        "directory mask" = "0775"; # New directories: rwxrwxr-x
        # "valid users" = "@${sambaUser}";
      };
    };
  };

  # Samba user must exist
  users.users.${sambaUser} = {
    isNormalUser = true;
    home = "/home/${sambaUser}";
    extraGroups = [sambaUser];
  };

  users.users.${username} = {
    extraGroups = [sambaUser];
  };

  # Create samba user group
  users.groups.${sambaUser} = {};

  # Avahi for service discovery (already enabled in your config)
  services.avahi = {
    publish = {
      enable = true;
      userServices = true;
    };

    # Advertise SMB shares
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
          <service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=Xserve</txt-record>
          </service>
        </service-group>
      '';
    };
  };
}
