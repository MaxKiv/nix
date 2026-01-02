{
  hostname,
  username,
  config,
  lib,
  ...
}: {
  imports = [
    ./tailscale
  ];

  config = {
    hardware.enableRedistributableFirmware = true;

    networking = {
      networkmanager = {
        enable = true;
        # NOTE: dramatic effect on bandwidth https://gist.github.com/jcberthon/ea8cfe278998968ba7c5a95344bc8b55
        # wifi.powersave = true;
      };
      hostName = hostname;

      # Manually set DNS
      # NOTE: when using tailscale this is overridden
      nameservers = lib.mkDefault [
        "1.1.1.1" # Cloudflare
        "8.8.8.8" # Doogle
      ];

      hosts = {
        "192.168.1.1" = ["router.local"];
        "192.168.1.2" = ["downtown.local"];
        "192.168.1.3" = ["terra.local"];
        "192.168.1.4" = ["rapanui.local"];
      };
    };

    # Setup wifi SSID and psk
    sops.secrets."wireless.env" = {};
    # The entire wireless.env file containing all network SSID and PSK is a
    # single secret, see:
    # https://www.reddit.com/r/NixOS/comments/zneyil/using_sopsnix_to_amange_wireless_secrets/
    networking.wireless.secretsFile = config.sops.secrets."wireless.env".path;
    # https://github.com/NixOS/nixpkgs/issues/342140
    # https://mynixos.com/nixpkgs/option/networking.wireless.secretsFile
    networking.wireless.networks = {
      home.pskRaw = "ext.home_psk";
      phone_personal.pskRaw = "ext.phone_personal_psk";
      phone_work.pskRaw = "ext.hotspot_psk";
      soof_spot.pskRaw = "ext.soof_spot_psk";
      leus.pskRaw = "ext.leus_psk";
    };

    users.users.${username} = {
      extraGroups = ["networkmanager"];
    };
  };
}
