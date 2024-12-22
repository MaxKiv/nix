{
  pkgs,
  username,
  ...
}: {
  # Thunar is a file explorer
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  services = {
    # Mount, trash, and other functionalities
    gvfs.enable = true;

    # Thumbnail support for images
    tumbler.enable = true;
  };
}
