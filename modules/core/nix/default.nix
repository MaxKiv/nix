{ home-manager, pkgs, username, ... }:

{
  # Required for nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.gc.automatic = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";

  # Setup home-manager as nixos module
  home-manager.users.${username} = {
    programs.home-manager.enable = true;
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "23.11";
    nixpkgs.config.allowUnfree = true;
  };
}
