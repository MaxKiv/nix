{ lib, config, pkgs, ... }:

let
  cfg = config.main-user;
in
{
  options.main-user = {
    enable
      = lib.mkEnableOption "enable user module";

    userName = lib.mkOption {
      default = "max";
      description = ''
        max
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.${cfg.userName} = {
      isNormalUser = true;
      createHome = true;
      initialPassword = "Proverdi12";
      extraGroups = [ "networkmanager" "wheel" ];
      description = "main user";
      shell = pkgs.bashInteractive;
    };

    users.users."root" = {
      initialPassword = "Proverdi12";
      shell = pkgs.bashInteractive;
    };
  };
}
