{
  pkgs,
  lib,
  config,
  ...
}:
with lib; {
  options.my.powerManager = mkOption {
    type = types.enum ["power-profiles-daemon" "auto-cpufreq"];
    default = "power-profiles-daemon";
    description = ''
      Choose power management backend: "power-profiles-daemon" or "auto-cpufreq"
    '';
  };

  config = mkMerge [
    (mkIf (config.my.powerManager == "power-profiles-daemon") {
      systemd.user.services.auto-power-profile = {
        wantedBy = ["default.target"];
        serviceConfig = {
          ExecStart = let
            script = pkgs.writeShellApplication {
              name = "auto-power-profile";
              text = builtins.readFile ./ppd-auto-power-profile.sh;
              runtimeInputs = with pkgs; [
                inotify-tools
                power-profiles-daemon
                coreutils
              ];
            };
          in "${script}/bin/auto-power-profile";
        };
      };
    })

    # Newer Power manager, seems better on wayland?
    (mkIf (config.my.powerManager == "auto-cpufreq") {
      services.auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo = "never";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };
    })
  ];
}
