{
  config,
  hostname,
  ...
}: let
  homeAssistantPort = 8234;
  nginxPort = 80;
  tailnet = "tilapia-dab";
in {
  networking.firewall = {
    allowedTCPPorts = [
      homeAssistantPort
      nginxPort
    ];
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "hass.${hostname}.${tailnet}.ts.net" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString homeAssistantPort}";
          proxyWebsockets = true;
        };
      };
    };
  };

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
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      http = {
        server_port = homeAssistantPort;
        use_x_forwarded_for = true;
        trusted_proxies = ["127.0.0.1"];
      };

      homeassistant = {
        external_url = "http://hass.tilapia-dab.ts.net";
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
