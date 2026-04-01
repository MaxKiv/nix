{
  config,
  username,
  lib,
  sshKeys,
  ...
}: let
  sambaUser = "nas";
  sambaExportPath = "/export";
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
        "guest account" = "nobody"; # windows needs this
        "map to guest" = "Bad User"; # windows needs this
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
        path = sambaExportPath;
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

  # Activation scripts run every time nixos switches build profiles. So if you're
  # pulling the user/samba password from a file then it will be updated during
  # nixos-rebuild. Again, in this example we're using sops-nix with a "samba" entry
  # to avoid cleartext password, but this could be replaced with a static path.
  system.activationScripts = {
    # The "init_smbpasswd" script name is arbitrary, but a useful label for tracking
    # failed scripts in the build output. An absolute path to smbpasswd is necessary
    # as it is not in $PATH in the activation script's environment. The password
    # is repeated twice with newline characters as smbpasswd requires a password
    # confirmation even in non-interactive mode where input is piped in through stdin.
    init_smbpasswd.text = ''
      /run/current-system/sw/bin/printf "$(/run/current-system/sw/bin/cat ${config.sops.secrets.samba.path})\n$(/run/current-system/sw/bin/cat ${config.sops.secrets.samba.path})\n" | /run/current-system/sw/bin/smbpasswd -sa ${sambaUser}
    '';
  };

  sops.secrets = {
    samba = {};
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

  users.users."nobody" = {
    extraGroups = ["nas"];
  };

  # Create samba user group
  users.groups.${sambaUser} = {
    gid = 982;
    members = [username "nas" "nobody"];
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
  };
}
