{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.powerManager;
in {
  options.my.powerManager = mkOption {
    type = types.enum ["power-profiles-daemon" "auto-cpufreq"];
    default = "power-profiles-daemon";
    description = ''
      Choose power management backend: "power-profiles-daemon" or "auto-cpufreq"
    '';
  };

  config = mkMerge [
    (mkIf (cfg == "power-profiles-daemon") {
      services.power-profiles-daemon.enable = true;
      services.auto-cpufreq.enable = false;
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
    (mkIf (cfg == "auto-cpufreq") {
      services.power-profiles-daemon.enable = false;
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
