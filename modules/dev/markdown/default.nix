{username, ...}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [markdown-oxide];
  };
}
