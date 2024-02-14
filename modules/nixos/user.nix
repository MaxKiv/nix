{ lib, config, pkgs, ... }:

let
  cfg = config.main-user;
in
{
  options.main-user = {
    # Allows consumer of this module to do main-user.enable = true;
    enable = lib.mkEnableOption "enable user module";

    # Allows consumer of this module to do main-user.userName = "Jantje"
    userName = lib.mkOption {
      default = "max";
      description = ''
        Max Kivits
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Setup main user
    users.users.${cfg.userName} = {
      isNormalUser = true;
      createHome = true;
      initialPassword = "Proverdi12";
      extraGroups = [ "networkmanager" "wheel" ];
      description = "${cfg.userName}";
      shell = pkgs.bashInteractive;
    };

    # Setup root user
    users.users."root" = {
      initialPassword = "Proverdi12";
      shell = pkgs.bashInteractive;
    };

    # Only Nix can mutate users
    users.mutableUsers = false;
  };
}
