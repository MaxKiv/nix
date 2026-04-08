# Nix config for a standalone machine learning container for immich
{
  config,
  pkgs,
  lib,
  ...
}: let
  mlPort = 3003;
  mlCacheDir = "/var/cache/immich-ml";
  # Update this to your server's IP/hostname
  # so Immich knows to query this machine for ML
  # Set in Immich admin UI: Settings → Machine Learning → URL
  # e.g. http://192.168.1.50:3003
in {
  # ---------------------------------------------------------------------------
  # Container runtime — podman is preferred on NixOS (rootless-friendly, no daemon)
  # ---------------------------------------------------------------------------
  virtualisation.podman = {
    enable = true;
    # Enables the Docker-compatible socket so `docker` CLI works if needed
    # dockerCompat = true;
  };

  # NVIDIA container toolkit — required for --gpus=all to work inside podman/docker
  hardware.nvidia-container-toolkit.enable = true;

  # ---------------------------------------------------------------------------
  # Persistent cache directory for downloaded ML models (~4–8 GB)
  # ---------------------------------------------------------------------------
  systemd.tmpfiles.rules = [
    "d ${mlCacheDir} 0755 root root -"
  ];

  # ---------------------------------------------------------------------------
  # Immich ML systemd unit
  # ---------------------------------------------------------------------------
  systemd.services.immich-machine-learning = {
    description = "Immich Machine Learning (CUDA)";
    # Start after the network and podman socket are ready
    after = ["network-online.target" "podman.socket"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    # Pull the image before starting if it is not present
    preStart = ''
      ${pkgs.podman}/bin/podman pull \
        ghcr.io/immich-app/immich-machine-learning:release-cuda || true
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "10s";

      # Remove any existing container with the same name so restarts are clean
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman rm -f immich-machine-learning"
      ];

      ExecStart = lib.concatStringsSep " " [
        "${pkgs.podman}/bin/podman run"
        "--name=immich-machine-learning"
        "--rm"
        # GPU passthrough
        "--gpus=all"
        # Port
        "-p ${toString mlPort}:${toString mlPort}"
        # Model cache volume
        "-v ${mlCacheDir}:/cache:rw"
        # Environment
        "-e MACHINE_LEARNING_WORKERS=1"
        "-e MACHINE_LEARNING_WORKER_TIMEOUT=120"
        "-e MACHINE_LEARNING_CACHE_FOLDER=/cache"
        "-e IMMICH_HOST=0.0.0.0"
        "-e IMMICH_PORT=${toString mlPort}"
        "ghcr.io/immich-app/immich-machine-learning:release-cuda"
      ];

      ExecStop = "${pkgs.podman}/bin/podman stop immich-machine-learning";

      # Give the model server a generous window to load on start/stop
      TimeoutStartSec = "300";
      TimeoutStopSec = "30";
    };
  };

  # ---------------------------------------------------------------------------
  # Firewall — allow Immich server to reach the ML port
  # Restrict source to your LAN if you prefer tighter rules:
  #   networking.firewall.extraRules = ''
  #     iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport ${toString mlPort} -j ACCEPT
  #   '';
  # ---------------------------------------------------------------------------
  networking.firewall.allowedTCPPorts = [mlPort];

  # ---------------------------------------------------------------------------
  # Wake-on-LAN stub (TODO: wire up to Immich server side)
  #
  # On this desktop:
  #   1. Enable WoL in BIOS/UEFI for the NIC.
  #   2. Find your NIC name: `ip link`
  #   3. Set the interface name below.
  #
  # From the Immich server you can then wake this machine with:
  #   nix-shell -p wol --run "wol <this-desktop-MAC>"
  #
  # A future improvement would be a small webhook/HTTP trigger on the server
  # that sends the magic packet and waits for port 3003 to become reachable
  # before Immich dispatches ML jobs.
  # ---------------------------------------------------------------------------
  # Uncomment and set your interface to enable WoL persistence across reboots:
  #
  # systemd.services."wol-enable" = {
  #   description = "Enable Wake-on-LAN on boot";
  #   after = ["network.target"];
  #   wantedBy = ["multi-user.target"];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${pkgs.ethtool}/bin/ethtool -s <INTERFACE> wol g";
  #   };
  # };
}
