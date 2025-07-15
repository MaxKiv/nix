{
  inputs,
  home-manager,
  config,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    postman # POST/GET API call GUI
    nmap
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # influxdb3 http endpoint
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8181 8000];
  };

  # Set static ip on ethernet interface
  networking.interfaces.enp0s20f0u1.ipv4.addresses = [
    {
      address = "192.168.0.1";
      prefixLength = 24;
    }
  ];

  home-manager.users.${username} = let
    workKeyPath = config.sops.secrets."ssh/work".path;
    personalKeyPath = config.sops.secrets."ssh/personal".path;
  in
    {
      config,
      pkgs,
      ...
    }: {
      programs.ssh = {
        matchBlocks = {
          "192.168.0.2" = {
            user = "root";
            identityFile = workKeyPath;
            forwardX11 = true;
            forwardX11Trusted = true;
            forwardAgent = true;
            extraOptions = {
              "XAuthLocation" = "${pkgs.xorg.xauth}/bin/xauth";
            };
          };
        };
      };
    };
}
