{
  config,
  username,
  lib,
  chaotic,
  ...
}: {
  imports = [
    chaotic.nixosModules.default # Adds chaotic binary cache, used for NordVPN
  ];

  options.my.nordvpn.enable = lib.mkEnableOption "Enable NordVPN setup via chaotic";

  config = lib.mkIf config.my.nordvpn.enable {
    chaotic.nordvpn.enable = true;

    networking.firewall = {
      enable = true;
      checkReversePath = false;
      allowedTCPPorts = [443];
      allowedUDPPorts = [1194];
    };

    users.users.${username} = {
      extraGroups = ["nordvpn"];
    };
  };
}
