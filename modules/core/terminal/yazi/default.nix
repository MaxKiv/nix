{
  username,
  inputs,
  ...
}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    programs.yazi = {
      enable = true;
      # package = inputs.yazi.packages.${pkgs.stdenv.hostPlatform.system}.default;
      shellWrapperName = "y";
    };

    stylix.targets.yazi.enable = true;
  };
}
