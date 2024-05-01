{ config, pkgs, username, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.bash;
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."pass/${username}".path;
    extraGroups = [ "wheel" "input" "video" "render" ];
  };

  # Setup root user
  users.users."root" = {
    hashedPasswordFile = config.sops.secrets."pass/root".path;
    shell = pkgs.bash;
  };

  sops.secrets = {
    "pass/${username}" = {
      neededForUsers = true;
    };

    "pass/root" = {
      neededForUsers = true;
    };
  };

  # Only Nix can mutate users
  users.mutableUsers = false;
}
