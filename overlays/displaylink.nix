{
  pkgs,
  inputs,
}: final: prev: let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in {
  # hyprland-displaylink = with inputs.hyprland.packages.${prev.system};
  #   (hyprland.override {
  #     wlroots = addPatches pkgs.wlroots [./patches/displaylink.patch];
  #   })
  #   .overrideAttrs (o: {
  #     pname = "${o.pname}-displaylink";
  #   });
  #
  # xdg-desktop-portal-hyprland-displaylink = with inputs.hyprland.packages.${prev.system};
  #   xdg-desktop-portal-hyprland.override {
  #     hyprland = pkgs.hyprland-displaylink;
  #   };

  sway-displaylink = let
    wlroots-sway = prev.wlroots.overrideAttrs (o: {
      src = prev.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "wlroots";
        repo = "wlroots";
        rev = "213bd88b4c0b9b36bf3b6faacd65929e37edb12e";
        sha256 = "sha256-ISsEN8D22PJPYObobUU5SL31TBPnY6TtKM62dzB9qbE=";
      };

      patches = [
        ./patches/displaylink.patch
      ];
      buildInputs = with final;
        [
          lcms
        ]
        ++ o.buildInputs;
    });

    sway-unwrapped =
      (prev.sway-unwrapped.overrideAttrs (o: {
        src = prev.fetchFromGitHub {
          owner = "swaywm";
          repo = "sway";
          rev = "cc342107690631cf1ff003fed0b1cdb072491c63";
          sha256 = "sha256-RzPlJSWeMIKV6mZAcQMooERJmjYCogfGT/NPYlJM7yM=";
        };

        mesonFlags = let
          inherit (pkgs.lib.strings) mesonEnable mesonOption;
        in [
          (mesonOption "sd-bus-provider" "libsystemd")
          (mesonEnable "tray" o.trayEnabled)
        ];
      }))
      .override {
        wlroots = wlroots-sway;
      };
  in
    prev.sway.override {
      inherit sway-unwrapped;
      extraOptions = ["--unsupported-gpu"];
    };
}
