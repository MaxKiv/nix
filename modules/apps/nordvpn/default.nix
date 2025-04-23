{
  config,
  username,
  lib,
  ...
}:
with lib; let
  cfg = config.my.nordvpn.enable;
in {
  options.my.nordvpn.enable = mkEnableOption "Enable NordVPN setup via chaotic";

  config = mkIf cfg {
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
