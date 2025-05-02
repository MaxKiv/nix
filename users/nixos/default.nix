{
  config,
  pkgs,
  username,
  ...
}: {
  # Define a user account
  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."pass/${username}".path;
    extraGroups = ["wheel" "input" "video" "render"];
  };

  # Setup root and user password
  sops.secrets = {
    "pass/${username}" = {
      neededForUsers = true;
    };
  };
}
