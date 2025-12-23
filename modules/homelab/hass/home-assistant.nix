{config, ...}: {
  networking.firewall = {
    allowedTCPPorts = [
      8234
    ];
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
      "ibeacon"
      "xiaomi_ble"

      "music_assistant"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      http.server_port = 8234;

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
