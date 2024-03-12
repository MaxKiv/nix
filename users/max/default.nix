{ config, pkgs, username, ... }:
{
  users.users = {
    ${username} = {
      shell = pkgs.bash;
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."pass/${username}".path;
      extraGroups = [ "wheel" "input" "video" "render" "dialout" ];
    };

    "root" = {
      hashedPasswordFile = config.sops.secrets."pass/root".path;
      shell = pkgs.bash;
    };

  };

  users.mutableUsers = false;
}

