{
  lib,
  pkgs,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.my.networking.can;
in {
  options.my.networking.can = {
    interfaces = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            bitrate = mkOption {
              type = types.int;
              default = 500000;
              description = "The bitrate in bit/s for the CAN interface.";
            };
          };
        }
      );
      default = {};
      description = "CAN interfaces to configure.";
    };
  };

  config = mkIf (cfg.interfaces != {}) {
    # Module to enable working with the PEAK CAN adapter
    # Add peak and generic can kernel modules
    boot.kernelModules = ["peak_usb" "can"];

    # CAN userspace utilities and tools (for use with Linux SocketCAN)
    environment.systemPackages = with pkgs; [can-utils];

    # Add user to the right usergroups
    users.users.${username}.extraGroups = ["dialout" "can"];

    # Add udev rule for PCAN adapter (confirm 0c72 is right with `lsusb`)
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0c72", MODE="0666"
    '';

    # Setup systemd service to set right CAN bitrate
    systemd.services =
      mapAttrs (name: interface: {
        description = "Setup ${name} CAN interface";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c '
              if ${pkgs.iproute2}/bin/ip link show ${name} &>/dev/null; then
                ${pkgs.iproute2}/bin/ip link set ${name} type can bitrate ${toString interface.bitrate};
                ${pkgs.iproute2}/bin/ip link set ${name} up;
              fi
            '
          '';
          ExecStop = "${pkgs.bash}/bin/bash -c 'if ${pkgs.iproute2}/bin/ip link show ${name} &>/dev/null; then ${pkgs.iproute2}/bin/ip link set ${name} down; fi'";
        };
      })
      cfg.interfaces;
  };
}
