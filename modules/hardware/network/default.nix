{
  hostname,
  username,
  config,
  ...
}: {
  networking = {
    networkmanager = {
      enable = true;

      # NOTE: dramatic effect on bandwidth https://gist.github.com/jcberthon/ea8cfe278998968ba7c5a95344bc8b55
      # wifi.powersave = true;
    };
    hostName = hostname;
  };

  # Setup wifi SSID and psk
  sops.secrets."wireless.env" = {};
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
    home.pskRaw = "ext.home_psk";
    hotspot.pskRaw = "ext.hotspot_psk";
    soof_spot.pskRaw = "ext.soof_spot_psk";
    leus.pskRaw = "ext.leus_psk";
  };

  users.users.${username} = {
    extraGroups = ["networkmanager"];
  };
}
