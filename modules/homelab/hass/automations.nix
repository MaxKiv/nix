# Contains all declarative Home Assistant automations
# inspo
# https://github.com/ymatsiuk/nixos-config/blob/f8890e08c61bc3763df993120576523f0e8fca34/homeassistant.nix#L844
let
  light_temperature_waking = 2000;
  light_temperature_day = 3200;
  light_temperature_night = 2000; # Kelvin
  light_brightness_night = 100; # %
in [
  {
    alias = "Sunrise: wake up lights";
    description = "Slowly enable lights when the sun rises";
    id = "1766420794196";
    mode = "single";
    triggers = [
      {
        trigger = "sun";
        id = "sunrise";
        event = "sunrise";
        offset = 0;
      }
    ];
    actions = [
      {
        action = "light.turn_on";
        metadata = {};
        data = {
          color_temp_kelvin = light_temperature_waking;
          transition = 300;
        };
        target = {
          entity_id = [
            "light.bollie"
            "light.signify_netherlands_b_v_lca016"
            "light.bedroom_light"
          ];
        };
      }
    ];
  }

  {
    alias = "Daytime lights";
    description = "Default lights during daytime";
    id = "1766420794197";
    mode = "single";
    triggers = [
      {
        trigger = "sun";
        id = "sunrise";
        event = "sunrise";
        offset = "01:00:00";
      }
    ];
    actions = [
      {
        action = "light.turn_on";
        metadata = {};
        data = {
          color_temp_kelvin = light_temperature_day;
          transition = 300;
        };
        target = {
          entity_id = [
            "light.bollie"
            "light.signify_netherlands_b_v_lca016"
            "light.bedroom_light"
          ];
        };
      }
    ];
  }

  {
    alias = "Sunset: dim & warm lights";
    description = "Dim lights and make them a warmer color when sun sets";
    id = "1766407082732";
    mode = "single";
    triggers = [
      {
        trigger = "sun";
        id = "sunset";
        event = "sunset";
        offset = 0;
      }
    ];
    actions = [
      {
        action = "light.turn_on";
        metadata = {};
        data = {
          color_temp_kelvin = light_temperature_night;
          brightness_pct = light_brightness_night;
          transition = 300;
        };
        target = {
          entity_id = [
            "light.bollie"
            "light.signify_netherlands_b_v_lca016"
            "light.bedroom_light"
          ];
        };
      }
    ];
  }
]
