{
  self,
  config,
  hostname,
  ...
}: let
  homeAssistantPort = 8234;
  serviceHostname = "home.demtah.top";
in {
  # Reverse proxy vhost settings
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "home.demtah.top" = {
        default = true;
        forceSSL = true;
        useACMEHost = serviceHostname;
        http2 = false;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString homeAssistantPort}";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };

  # Set up acme-dns
  security.acme.certs."${serviceHostname}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };

  # Set up Home Assistant
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"

      "hue"
      "zha"

      "androidtv_remote"
      "androidtv"

      "ibeacon"
      "xiaomi_ble"

      "cast"
      "music_assistant"
      "tailscale"
      "steam_online"
      "spotify"

      "tuya"

      "weatherflow"
      "accuweather"
    ];

    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      http = {
        # server_host = "::1";
        server_port = homeAssistantPort;
        use_x_forwarded_for = true;
        trusted_proxies = ["127.0.0.1"];
      };

      homeassistant = {
        external_url = "https://home.demtah.top";
        internal_url = "http://127.0.0.1:8234";
      };

      # Automations - declarative
      "automation manual" =
        import ./automations.nix;

      # Automations - imperative
      "automation ui" = "!include automations.yaml";

      # Scenes - declarative
      "scene manual" = [];

      # Scenes - imperative
      "scene ui" = "!include scenes.yaml";
    };
  };

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
  ];
}

