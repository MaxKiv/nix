{
  config,
  pkgs,
  username,
  ...
}: {
  # Deploy aoc session token
  sops.secrets."aoc" = {
    mode = "0400";
    path = "/home/${username}/.config/adventofcode.session";
    owner = "${username}";
  };

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [aoc-cli];
  };
}
