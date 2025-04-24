{
  pkgs,
  config,
  ...
}: {
  # environment.systemPackages = with pkgs; [
  #   displaylink
  # ];

  # nixpkgs.config.displaylink = {
  #   enable = true;
  #   # Use a fixed path relative to the repository
  #   driverFile = ./displaylink-610.zip;
  #   # Provide a fixed hash that you'll get after downloading the file
  #   sha256 = "1b3w7gxz54lp0hglsfwm5ln93nrpppjqg5sfszrxpw4qgynib624"; # Add the hash here after downloading and running nix-prefetch-url file://$(pwd)/modules/displaylink/displaylink-600.zip
  # };

  # Load the evdi module for DisplayLink
  boot.extraModulePackages = with config.boot.kernelPackages; [
    evdi
  ];
  boot.kernelModules = ["evdi"];
}
