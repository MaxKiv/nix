{pkgs, ...}: {

  # programs.nautilus-open-any-terminal = {
  #   enable = true;
  #   terminal = "alacritty";
  # };

  environment.systemPackages = with pkgs; [
    nautilus
  ];

  services = {
    # Mount, trash, and other functionalities
    gvfs.enable = true;
  };
}
