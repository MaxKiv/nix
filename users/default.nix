{
  config,
  pkgs,
  username,
  ...
}: {
  # Setup root user
  users.users."root" = {
    hashedPasswordFile = config.sops.secrets."pass/root".path;
    # shell = pkgs.bash;
  };

  # Setup root and user password
  sops.secrets = {
    "pass/root" = {
      neededForUsers = true;
    };
  };

  # Only Nix can mutate users
  users.mutableUsers = false;

  imports = [
    ./${username}
  ];
}
