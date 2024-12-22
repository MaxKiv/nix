{ inputs, pkgs, username, ... }:
{

  # allow spotify to be installed if you don't have unfree enabled already
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "spotify" ];

  home-manager.users.${username} =
    { config
    , pkgs
    , ...
    }: {

      imports = [
        # inputs.spicetify-nix.nixosModules.default
        inputs.spicetify-nix.homeManagerModules.default
      ];

      programs.spicetify =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        in
        {
          enable = true;
          enabledExtensions = with spicePkgs.extensions; [
            adblock
            autoVolume
            betterGenres
            copyToClipboard
            featureShuffle
            fullAlbumDate
            goToSong
            # hidePodcasts
            history
            keyboardShortcut # https://spicetify.app/docs/advanced-usage/extensions/#keyboard-shortcut
            playNext
            savePlaylists
            shuffle # shuffle+ (special characters are sanitized out of extension names)
            songStats
          ];
          # Managed by stylix
          # theme = spicePkgs.themes.catppuccin;
          # colorScheme = "mocha";
        };
    };
}
