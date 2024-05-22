{ hostname, username, sops, ... }:

{
  networking = {
    networkmanager = {
      enable = true;

      # NOTE: dramatic effect on bandwidth https://gist.github.com/jcberthon/ea8cfe278998968ba7c5a95344bc8b55
      # wifi.powersave = true; 
    };
    hostName = hostname;
  };

  # Setup wifi SSID and psk
  sops.secrets."wireless.env" = { };
  # The entire wireless.env file containing all network SSID and PSK is a
  # single secret, see:
  # https://www.reddit.com/r/NixOS/comments/zneyil/using_sopsnix_to_amange_wireless_secrets/
  networking.wireless.environmentFile = sops.secrets."wireless.env".path;
  # Secrets (PSKs, passwords, etc.) can be provided without adding them to the
  # world-readable Nix store by defining them in the environment file and
  # referring to them in option networking.wireless.networks with the syntax
  # @varname@. 
  networking.wireless.networks = {
    "@home_uuid@" = {
      psk = "@home_psk@";
    };

    "@hotspot_uuid@" = {
      psk = "@hotspot_psk@";
    };

    "@leushuis_uuid@" = {
      psk = "@leushuis_psk@";
    };
  };

  users.users.${username} = {
    extraGroups = [ "networkmanager" ];
  };
}

