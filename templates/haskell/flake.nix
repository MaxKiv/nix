{
  description = "A development environment with GHC, Stack, Haskell Language Server etc";

  inputs = {
    your-nixos-flake.url = "github:maxkiv/nix";
    nixpkgs.follows = "your-nixos-flake/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Outputs this flake produces
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        hPkgs = pkgs.haskell.packages."ghc927"; # need to match Stackage LTS version from stack.yaml snapshot

        hspec_2_7_10 = pkgs.haskell.lib.doJailbreak hPkgs.hspec_2_7_10;
        text_2_0_2 = hPkgs.text_2_0_2; # Ensure this version is used

        myDevTools = [
          # GHC compiler in the desired version (will be available on PATH)
          (hPkgs.ghcWithPackages (hpkgs: [
            # List of packages you want GHC to know about
            #hpkgs.xmonad
            hspec_2_7_10
            text_2_0_2
            # hPkgs.hspec_2_7_10
            # hPkgs.hspec-discover_2_7_10
            # hPkgs.hspec-core_2_7_10
            # hPkgs.hspec-meta_2_7_8
            # (hPkgs.lib.dontCheck hPkgs.hspec_2_7_10)
          ]))

          hPkgs.ghcid # Continuous terminal Haskell compile checker
          hPkgs.hlint # Haskell codestyle checker
          hPkgs.hoogle # Lookup Haskell documentation
          hPkgs.fast-tags # Lookup Haskell documentation
          hPkgs.haskell-language-server # LSP server for editor
          hPkgs.implicit-hie # auto generate LSP hie.yaml file from cabal
          hPkgs.retrie # Haskell refactoring tool
          # hPkgs.cabal-install
          stack-wrapped
          pkgs.zlib # External C library needed by some Haskell packages
          pkgs.ormolu
        ];

        # Wrap Stack to work with our Nix integration. We don't want to modify
        # stack.yaml so non-Nix users don't notice anything.
        # - no-nix: We don't want Stack's way of integrating Nix.
        # --system-ghc    # Use the existing GHC on PATH (will come from this Nix file)
        # --no-install-ghc  # Don't try to install GHC if no matching GHC found on PATH
        stack-wrapped = pkgs.symlinkJoin {
          name = "stack"; # will be available as the usual `stack` in terminal
          paths = [ pkgs.stack ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/stack \
              --add-flags "\
                --no-nix \
                --system-ghc \
                --no-install-ghc \
              "
          '';
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = myDevTools;

          # Make external Nix c libraries like zlib known to GHC, like
          # pkgs.haskell.lib.buildStackProject does
          # https://github.com/NixOS/nixpkgs/blob/d64780ea0e22b5f61cd6012a456869c702a72f20/pkgs/development/haskell-modules/generic-stack-builder.nix#L38
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath myDevTools;
        };
      });
}
