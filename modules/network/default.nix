{
  hostname,
  username,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./tailscale
    ./avahi
  ];

  config = {
    environment.systemPackages = with pkgs; [
      dig
    ];

    hardware.enableRedistributableFirmware = true;

    networking = {
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

      networkmanager = {
        enable = true;
        # NOTE: dramatic effect on bandwidth https://gist.github.com/jcberthon/ea8cfe278998968ba7c5a95344bc8b55
        # wifi.powersave = true;

        # Declare Networkmanager profiles
        # Generate in /etc/NetworkManager/system-connections
        ensureProfiles = {
          environmentFiles = [
            config.sops.secrets."wifi/personal_phone".path
            config.sops.secrets."wifi/work_phone".path
            config.sops.secrets."wifi/soof_phone".path
            config.sops.secrets."wifi/home".path
            config.sops.secrets."wifi/leus".path
          ];

          profiles = {
            "home" = {
              connection = {
                id = "home";
                interface-name = "wlp3s0";
                type = "wifi";
                uuid = "62a8c622-0485-4e73-8fac-771d741e55d3";
              };
              ipv4 = {
                method = "auto";
              };
              ipv6 = {
                addr-gen-mode = "stable-privacy";
                method = "auto";
              };
              proxy = {};
              wifi = {
                mode = "infrastructure";
                ssid = "$HOME_SSID";
              };
              wifi-security = {
                key-mgmt = "wpa-psk";
                psk = "$HOME_PSK";
              };
            };

            "leus" = {
              connection = {
                id = "leus";
                interface-name = "wlp3s0";
                permissions = "user:max:;";
                timestamp = "1741776118";
                type = "wifi";
                uuid = "40d0f255-9891-42d9-b31b-3bc8a826e48c";
              };
              ipv4 = {
                dns = "8.8.8.8;1.1.1.1;";
                method = "auto";
              };
              ipv6 = {
                addr-gen-mode = "stable-privacy";
                method = "auto";
              };
              proxy = {};
              wifi = {
                mode = "infrastructure";
                ssid = "$LEUS_SSID";
              };
              wifi-security = {
                key-mgmt = "wpa-psk";
                psk-flags = "1";
                psk = "$LEUS_PSK";
              };
            };

            "personal_phone" = {
              connection = {
                id = "personal_phone";
                metered = "1";
                permissions = "user:max:;";
                timestamp = "1764261026";
                type = "wifi";
                uuid = "5c2762df-bdba-4328-a8bb-d6360867b615";
              };
              ipv4 = {
                dns = "1.1.1.1;";
                ignore-auto-dns = "true";
                method = "auto";
              };
              ipv6 = {
                addr-gen-mode = "stable-privacy";
                method = "auto";
              };
              proxy = {};
              wifi = {
                mode = "infrastructure";
                ssid = "$PERSONAL_PHONE_SSID";
              };
              wifi-security = {
                key-mgmt = "wpa-psk";
                psk-flags = "1";
                psk = "$PERSONAL_PHONE_PSK";
              };
            };

            "work_phone" = {
              connection = {
                id = "work_phone";
                interface-name = "wlp3s0";
                type = "wifi";
                uuid = "b7f11ede-4248-4632-b69f-0a3864d5f3cf";
              };
              ipv4 = {
                method = "auto";
              };
              ipv6 = {
                addr-gen-mode = "default";
                method = "auto";
              };
              proxy = {};
              wifi = {
                mode = "infrastructure";
                ssid = "$WORK_PHONE_SSID";
              };
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = "$WORK_PHONE_PSK";
              };
            };

            "soof_phone" = {
              connection = {
                id = "soof_phone";
                interface-name = "wlp3s0";
                timestamp = "1741769933";
                type = "wifi";
                uuid = "a0436522-76ef-45e9-a7e5-45031e534350";
              };
              ipv4 = {
                dns = "8.8.8.8;1.1.1.1;";
                method = "auto";
              };
              ipv6 = {
                addr-gen-mode = "stable-privacy";
                method = "auto";
              };
              proxy = {};
              wifi = {
                mode = "infrastructure";
                ssid = "$SOOF_PHONE_SSID";
              };
              wifi-security = {
                key-mgmt = "wpa-psk";
                psk = "$SOOF_PHONE_PSK";
              };
            };
          };
        };
      };
    };

    sops.secrets = {
      "wifi/home" = {};
      "wifi/leus" = {};
      "wifi/personal_phone" = {};
      "wifi/work_phone" = {};
      "wifi/soof_phone" = {};
    };

    # # Setup wifi SSID and psk
    # sops.secrets."wireless.env" = {};
    # # The entire wireless.env file containing all network SSID and PSK is a
    # # single secret, see:
    # # https://www.reddit.com/r/NixOS/comments/zneyil/using_sopsnix_to_amange_wireless_secrets/
    # networking.wireless.secretsFile = config.sops.secrets."wireless.env".path;
    # # https://github.com/NixOS/nixpkgs/issues/342140
    # # https://mynixos.com/nixpkgs/option/networking.wireless.secretsFile
    # networking.wireless.networks = {
    #   home.pskRaw = "ext:home_psk";
    #   phone_personal.pskRaw = "ext:phone_personal_psk";
    #   phone_work.pskRaw = "ext:hotspot_psk";
    #   soof_spot.pskRaw = "ext:soof_spot_psk";
    #   leus.pskRaw = "ext:leus_psk";
    # };

    users.users.${username} = {
      extraGroups = ["networkmanager"];
    };
  };
}
