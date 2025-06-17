{
pkgs,
inputs,
username,
...
}: {
  # https://nixos.wiki/wiki/Docker

  # Enable Docker
  virtualisation = {
    docker.enable = true;
  };
  users.users.${username}.extraGroups = [ "docker" ];

  # Change data root
  virtualisation.docker.daemon.settings = {
    data-root = "/some-place/to-store-the-docker-data";
  };

  # Turn of the userland-proxy, which is mostly used in Windows
  virtualisation.docker.daemon.settings = {
    userland-proxy = false;
    experimental = true;
    metrics-addr = "0.0.0.0:9323";
    ipv6 = true;
    fixed-cidr-v6 = "fd00::/80";
  };


  # Enable GPU passthrough
  hardware.nvidia-container-toolkit.enable = true;
  # Then run a container with
  # --device=nvidia.com/gpu=all 
}
