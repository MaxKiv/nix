{
  lib,
  pkgs,
  config,
  ...
}:
with lib; {
  # Module to get displaylink to work
  # https://wiki.nixos.org/wiki/Displaylink
  options.my.displaylink.enable = lib.mkEnableOption "Enable Displaylink Displays";

  config = lib.mkIf config.my.displaylink.enable {
    # Add the prefetched displaylink driver package to the system
    environment.systemPackages = with pkgs; [
      displaylink
    ];

    # services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
    services.xserver.videoDrivers = ["displaylink"];

    # Enable the displaylink manager service
    systemd.packages = [pkgs.displaylink];
    systemd.services.dlm = {
      wantedBy = ["multi-user.target"];
      serviceConfig.ExecStart = mkForce "${pkgs.displaylink}/bin/DisplayLinkManager";
    };

    # Explicitly create displaylink ethernet interface
    networking.networkmanager = {
      unmanaged = ["enp72s0u2u3"];
      ethernet.macAddress = "preserve";
    };
    systemd.network.netdevs."40-displaylink" = {
      netdevConfig = {
        Name = "enp72s0u2u3";
        Kind = "ether";
      };
    };

    # DisplayLink firmware loading:
    # hardware.firmware = [
    #   (pkgs.runCommand "displaylink-firmware" {} ''
    #     mkdir -p $out/lib/firmware/displaylink
    #     cp ${pkgs.displaylink}/lib/*.spkg $out/lib/firmware/displaylink/
    #   '')
    # ];

    # Load the evdi module for DisplayLink
    boot.extraModulePackages = with config.boot.kernelPackages; [
      evdi
    ];
    boot.kernelModules = ["evdi" "cdc_ncm" "usbnet"];

    environment.variables = {
      WLR_EVDI_RENDER_DEVICE = "/dev/dri/card0";
    };

    # nixpkgs.overlays = [
    #   (final: prev: {
    #     sway = prev.sway.overrideAttrs (old: {
    #       wlroots = prev.wlroots_0_18.overrideAttrs (wlrootsOld: {
    #         patches =
    #           (wlrootsOld.patches or [])
    #           ++ [
    #             (prev.fetchpatch {
    #               url = "https://gitlab.freedesktop.org/wlroots/wlroots/uploads/bd115aa120d20f2c99084951589abf9c/DisplayLink_v2.patch";
    #               hash = "sha256-vWQc2e8a5/YZaaHe+BxfAR/Ni8HOs2sPJ8Nt9pfxqiE=";
    #             })
    #           ];
    #       });
    #     });
    #   })
    # ];

    # nixpkgs.overlays = [
    #   (final: prev: {
    #     wlroots_0_18 = prev.wlroots_0_18.overrideAttrs (old: {
    #       patches =
    #         (old.patches or [])
    #         ++ [
    #           (prev.fetchpatch {
    #             url = "https://gitlab.freedesktop.org/wlroots/wlroots/uploads/bd115aa120d20f2c99084951589abf9c/DisplayLink_v2.patch";
    #             hash = "sha256-vWQc2e8a5/YZaaHe+BxfAR/Ni8HOs2sPJ8Nt9pfxqiE=";
    #           })
    #         ];
    #     });
    #   })
    # ];

    # nixpkgs.config.displaylink = {
    #   enable = true;
    #   # Use a fixed path relative to the repository
    #   driverFile = ./displaylink-610.zip;
    #   # Provide a fixed hash that you'll get after downloading the file
    #   sha256 = "1b3w7gxz54lp0hglsfwm5ln93nrpppjqg5sfszrxpw4qgynib624"; # Add the hash here after downloading and running nix-prefetch-url file://$(pwd)/modules/displaylink/displaylink-600.zip
    # };
  };
}
