{
  stdenv,
  lib,
  unzip,
  util-linux,
  libusb1,
  makeBinaryWrapper,
  requireFile,
  pkgs,
}: let
  bins =
    if stdenv.hostPlatform.system == "x86_64-linux"
    then "x64-ubuntu-1604"
    else if stdenv.hostPlatform.system == "i686-linux"
    then "x86-ubuntu-1604"
    else if stdenv.hostPlatform.system == "aarch64-linux"
    then "aarch64-linux-gnu"
    else throw "Unsupported architecture";
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    util-linux
    libusb1
    pkgs.evdi
  ];
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "displaylink";
    version = "6.0.0-24";

    src = requireFile rec {
      name = "displaylink-611.zip";
      sha256 = lib.fakeSha256;
      message = ''
        In order to install the DisplayLink drivers, you must first
        comply with DisplayLink's EULA and download the binaries and
        sources from here:

        https://www.synaptics.com/products/displaylink-usb-graphics-software-ubuntu-611

        Once you have downloaded the file, please use the following
        commands and re-run the installation:

        mv \$PWD/"DisplayLink USB Graphics Software for Ubuntu6.1.1-EXE.zip" \$PWD/${name}
        nix-prefetch-url file://\$PWD/${name}
      '';
    };

    nativeBuildInputs = [
      makeBinaryWrapper
      unzip
    ];

    unpackPhase = ''
      runHook preUnpack
      unzip $src
      chmod +x displaylink-driver-${finalAttrs.version}.run
      ./displaylink-driver-${finalAttrs.version}.run --target . --noexec --nodiskspace
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      install -Dt $out/lib/displaylink *.spkg
      install -Dm755 ${bins}/DisplayLinkManager $out/bin/DisplayLinkManager
      mkdir -p $out/lib/udev/rules.d $out/share
      cp ${./99-displaylink.rules} $out/lib/udev/rules.d/99-displaylink.rules
      patchelf \
        --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) \
        --set-rpath ${libPath} \
        $out/bin/DisplayLinkManager
      wrapProgram $out/bin/DisplayLinkManager \
        --chdir "$out/lib/displaylink"

      # We introduce a dependency on the source file so that it need not be redownloaded everytime
      echo $src >> "$out/share/workspace_dependencies.pin"
      runHook postInstall
    '';

    dontStrip = true;
    dontPatchELF = true;

    meta = with lib; {
      description = "DisplayLink DL-7xxx, DL-6xxx, DL-5xxx, DL-41xx and DL-3x00 Driver for Linux";
      homepage = "https://www.displaylink.com/";
      hydraPlatforms = [];
      license = licenses.unfree;
      mainProgram = "DisplayLinkManager";
      maintainers = with maintainers; [abbradar];
      platforms = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
      ];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
    };
  })
