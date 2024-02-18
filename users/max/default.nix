{ pkgs, username, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.bash;
    isNormalUser = true;
    initialPassword = "Proverdi12";
    extraGroups = [ "wheel" "input" "video" "render" ];
    description = "It's me!";
  };

  # Setup root user
  users.users."root" = {
    initialPassword = "Proverdi12";
    shell = pkgs.bash;
  };

  # Only Nix can mutate users
  users.mutableUsers = false;
}
