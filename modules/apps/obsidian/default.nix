{
  pkgs,
  username,
  ...
}: {
  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
  ];

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [obsidian];
  };
}
