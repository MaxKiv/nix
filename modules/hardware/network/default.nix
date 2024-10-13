{ hostname, username, chaotic, config, ... }:

{
  imports = [
    chaotic.nixosModules.default # Adds chaotic binary cache, used for NordVPN
  ];

  # Setup for NordVPN
  chaotic.nordvpn.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = false;
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 1194 ];
  };

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
  networking.wireless.secretsFile = config.sops.secrets."wireless.env".path;
  # Secrets (PSKs, passwords, etc.) can be provided without adding them to the
  # world-readable Nix store by defining them in the environment file and
  # referring to them in option networking.wireless.networks with the syntax
  # @varname@. 
  # TODO: XX probably broke this, see:
  # https://github.com/NixOS/nixpkgs/issues/342140
  # https://mynixos.com/nixpkgs/option/networking.wireless.secretsFile
  networking.wireless.networks = {
    home.psk = "@home_psk@";
    hotspot.psk = "@hotspot_psk@";
    leushuis.psk = "@leushuis_psk@";
  };

  users.users.${username} = {
    extraGroups = [ "networkmanager" "nordvpn" ];
  };
}

