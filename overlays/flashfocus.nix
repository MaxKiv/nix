# overlays/flashfocus.nix
final: prev: {
  flashfocus = prev.flashfocus.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace pyproject.toml --replace "cffi>=1.11,<2.0" "cffi>=1.11"
      '';
  });
}
