{
  config,
  username,
  lib,
  sshKeys,
  ...
}: let
  sambaUser = "nas";
  sambaExportPath = "/data";
in {
  # Host Setup:
  # Set up sambaUser password: `sudo smbpasswd -a nas`
  # Check samba share directory permissions with `ls -ld /nas/data`, should be owned by ${sambaUser}
  # If not, change with `sudo chown -R ${sambaUser}:${sambaUser} /nas/data`
  #
  # Client Setup:
  # sudo mount -t cifs //192.168.1.2/data /mnt/nas -o vers=3.1.1,guest,uid=$(id -u max),gid=$(id -g max),file_mode=0775,dir_mode=0775
  # Make sure the clients user is part of the ${sambaUser} group
  #
  # Windows clients:
  # in explorer: \\${SambaHostIp}\data

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
        # "server min protocol" = "SMB2";
        # "server max protocol" = "SMB3";

        # Authentication settings
        "guest account" = "nobody"; # windows needs this
        "map to guest" = "Bad User"; # windows needs this
        "invalid users" = ["root"];

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
        path = sambaExportPath;
        browseable = "yes";
        writable = "true";
        "guest ok" = "yes";
        "read only" = "no";
        "force user" = sambaUser;
        "force group" = sambaUser;
        "create mask" = "0666"; # New files: rw-rw-rw-
        "directory mask" = "0777"; # New directories: rwxrwxrwx
        # "valid users" = "@${sambaUser}";
      };
    };
  };

  # Create samba user, add them to data group to allow SMB clients to touch slow pool
  users.users.${sambaUser} = {
    isNormalUser = true;
    home = "/home/${sambaUser}";
    extraGroups = [sambaUser "data"];
  };

  users.users.${username} = {
    extraGroups = [sambaUser];
  };

  # Create samba user group
  users.groups.${sambaUser} = {
    gid = 982;
    members = [username "nas"];
  };

  # Enable web service discovery daemon, should allow windows clients to find the samba share
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # Avahi for service discovery (already enabled in your config)
  services.avahi = {
    publish = {
      enable = true;
      userServices = true;
    };
    nssmdns4 = true;
    openFirewall = true;

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
