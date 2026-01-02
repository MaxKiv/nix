{
  hostname,
  username,
  config,
  lib,
  ...
}:
with lib; let
  tailCfg = config.my.networking.tailscale;
in {
  options.my.networking.tailscale = {
    enable = mkEnableOption "Enable tailscale on this device";

    nodeType = mkOption {
      type = types.enum ["client" "server"];
      default = "client";
      description = ''
        Choose what tailscale node type this device is.
      '';
    };
  };

  config = mkIf tailCfg.enable {
    imports = [
      ./tailscale/${tailCfg.nodeType}.nix
    ];
  };
}
