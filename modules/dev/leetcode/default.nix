{
  config,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    config,
    osConfig,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
        # vsc-leetcode-cli
        leetcode-cli
      ];
  };
}
