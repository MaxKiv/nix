{
  inputs,
  home-manager,
  pkgs,
  username,
  ...
}: {
  # Required for nix flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set system flake registry to speed up nix shells
  # See: https://yusef.napora.org/blog/pinning-nixpkgs-flake/
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.settings.flake-registry = "${inputs.flake-registry}/flake-registry.json";
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # For legacy commands

  # Trust current user, allows us to add binary caches etc
  nix.settings.trusted-users = [username];

  # Perform automatic garbage collection of the nix store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Optimize storage
  # You can also manually optimize the store via:
  #    nix-store --optimise
  # Refer to the following link for more details:
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";

  # Make sure nix LSP is available
  environment.systemPackages = [
    pkgs.nil
  ];

  # Use system level nixpkgs, this captures our overlays too
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
  home-manager.useGlobalPkgs = true;
  home-manager.verbose = true;

  # Setup home-manager as nixos module
  home-manager.users.${username} = {
    programs.home-manager.enable = true;
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "23.11";
  };

  # Enable nix-ld to use dynamically linked executables with hardcoded paths
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  # Enable envfs for fhs compatibility
  services.envfs.enable = true;
}
