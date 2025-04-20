{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
  ];

  services = {
    # Mount, trash, and other functionalities
    gvfs.enable = true;
  };
}
