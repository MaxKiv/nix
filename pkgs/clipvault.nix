{
  lib,
  rustPlatform,
  fetchFromGitHub,
  wl-clipboard,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "clipvault";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Rolv-Apneseth";
    repo = "clipvault";
    rev = "v${version}";
    sha256 = "sha256-ahhbUGijNZOjZ/egjdecn/4M6Nicq7PDDac09FNZz/Y=";
  };

  cargoHash = "sha256-Mm0att6zu9Yknoa9NBsdrA8lz1o0Q6FzWS0UU+1f/f0=";
  doCheck = false;

  nativeBuildInputs = [pkg-config];
  propagatedBuildInputs = [wl-clipboard];

  meta = with lib; {
    description = "Clipboard history manager for Wayland";
    homepage = "https://github.com/Rolv-Apneseth/clipvault";
    license = licenses.agpl3Only;
  };
}
