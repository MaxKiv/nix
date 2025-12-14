{
  pkgs,
  username,
  ...
}: {
  # environment.systemPackages = with pkgs; [
  #   element-desktop
  # ];

  # https://home-manager-options.extranix.com/?query=element&releae=master
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    programs.element-desktop.enable = true;
  };
}
