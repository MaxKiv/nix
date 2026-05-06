{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.pasteImage;

  # Pulls the script from the same directory as this module file.
  # Using builtins.path gives it a stable store path and a clean name.
  scriptSrc = builtins.path {
    path = ./paste-image.sh;
    name = "paste-image.sh";
  };

  pasteImagePkg = pkgs.stdenv.mkDerivation {
    pname = "paste-image";
    version = "1.0.0";

    src = scriptSrc;

    # No build phase — just patch shebangs and install.
    dontUnpack = true;

    nativeBuildInputs = [pkgs.makeWrapper];

    installPhase = ''
      install -Dm755 $src $out/bin/paste-image
    '';

    # Wrap the script so runtime deps are always on PATH,
    # regardless of what the calling shell has available.
    postFixup = let
      # Build the runtime PATH from whichever clipboard tool is available.
      # All three are included; the script itself picks the right one at runtime.
      runtimeDeps = lib.makeBinPath (
        [
          pkgs.bash
          pkgs.coreutils
        ]
        ++ lib.optionals cfg.enableXClip [pkgs.xclip]
        ++ lib.optionals cfg.enableWlClipboard [pkgs.wl-clipboard]
      );
    in ''
      wrapProgram $out/bin/paste-image \
        --prefix PATH : ${runtimeDeps}
    '';

    meta = {
      description = "Paste clipboard image into an Obsidian/nvim vault";
      mainProgram = "paste-image";
    };
  };
in {
  options.my.programs.pasteImage = {
    enable = lib.mkEnableOption "paste-image clipboard-to-vault script";

    enableXClip = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include xclip in the runtime PATH (X11).";
    };

    enableWlClipboard = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include wl-paste in the runtime PATH (Wayland).";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pasteImagePkg;
      defaultText = lib.literalExpression "derived from ./paste-image.sh";
      description = "The paste-image package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];
  };
}
