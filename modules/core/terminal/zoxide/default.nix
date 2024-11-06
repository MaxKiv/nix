{
  config,
  pkgs,
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
    home.packages = with pkgs; [zoxide];

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
