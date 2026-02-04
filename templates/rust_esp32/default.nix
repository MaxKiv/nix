{
  pkgs,
  system,
  esp-dev,
  self,
  ...
}:
let
  toolchainVersion = "1.88.0.0";

  espRustSource = pkgs.stdenv.mkDerivation {
    name = "esp-rust-source";

    src = pkgs.fetchurl {
      url = "https://github.com/esp-rs/rust-build/releases/download/v${toolchainVersion}/rust-src-${toolchainVersion}.tar.xz";
      sha256 = "sha256-m35u//UHO7uFtQ5mn/mVhNuJ1PCsuljgkD3Rmv3uuaE=";
    };

    unpackPhase = ''
      mkdir -p $out
      tar -xf $src -C $out --strip-components=1
    '';

    patchPhase = ''
      patchShebangs $out/install.sh
    '';

    outputs = [ "out" ];

    installPhase = ''
      $out/install.sh --destdir=$out --prefix="" --disable-ldconfig
      runHook postInstall
    '';
  };

  systemMap = {
    x86_64-linux = {
      systemSlug = "x86_64-unknown-linux-gnu";
      hash = "sha256-dFNJFHSl9yiyRIFlHUPLzq+S9438q+fLiCxr8h/uBQU=";
    };
    aarch64-linux = {
      systemSlug = "aarch64-unknown-linux-gnu";
      hash = "sha256-gXs4aujsORQM7pH8uVddhtoQq0Qq0avsJpUr6BISxV4=";
    };
    x86_64-darwin = {
      systemSlug = "x86_64-apple-darwin";
      hash = "sha256-Y3X1Th7GUfxK87MeXSz4vkfNaam5Y2msXk2IxOD05Bg=";
    };
    aarch64-darwin = {
      systemSlug = "aarch64-apple-darwin";
      hash = "sha256-kuxLe/Y4HRNY1hwTcywMfEeIfhh0suJKnMe9ArFn2zo=";
    };
  };

  espRustToolchain = pkgs.stdenv.mkDerivation {
    name = "esp-rust-toolchain";

    src = pkgs.fetchurl {
      url = "https://github.com/esp-rs/rust-build/releases/download/v${toolchainVersion}/rust-${toolchainVersion}-${systemMap.${system}.systemSlug}.tar.xz";
      sha256 = systemMap.${system}.hash;
    };

    buildInputs = with pkgs; [
      espRustSource
      libgcc
      libz
      libcxx
      autoPatchelfHook
    ];

    unpackPhase = ''
      mkdir -p $out
      tar -xf $src -C $out --strip-components=1
    '';

    patchPhase = ''
      patchShebangs $out/install.sh
    '';

    installPhase = ''
      chmod +x $out/install.sh
      sh $out/install.sh --destdir=$out --prefix="" --disable-ldconfig
      cp -rf ${espRustSource}/rust-src/lib/rustlib/* $out/lib/rustlib/
      runHook postInstall
    '';
  };

  combinedVendoredCargoDeps = pkgs.stdenv.mkDerivation {
    name = "combined-vendored-cargo-deps";
    buildInputs = with pkgs; [ rsync ];

    unpackPhase = ''
      export src=""
    '';

    stdDeps = pkgs.rustPlatform.fetchCargoVendor {
      src = "${espRustSource}/rust-src/lib/rustlib/src/rust/library";
      hash = "sha256-cgbLavzIOXFABPbpqaS0T6n6xQjb+icRhmJ5R/KvPsU=";
    };

    selfDeps = pkgs.rustPlatform.fetchCargoVendor {
      src = ../.;
      hash = "sha256-e8+F+9SRs22EyHDsLihLGWRpI2AW8BYFOL90yTBIuc4=";
    };

    buildPhase = ''
      mkdir -p $out
      rsync -av "$stdDeps/" $out/
      rsync -av "$selfDeps/" $out/
    '';
  };

  buildConfig = {
    nativeBuildInputs = with pkgs; [
      espRustToolchain
      espflash

      esp-dev.packages.${system}.esp-idf-esp32
      pkg-config
      cmake
      ninja
      python3
      ldproxy

      rust-bindgen
    ];

    buildInputs = with pkgs; [
      (rustPlatform.bindgenHook.override { inherit (pkgs.llvmPackages_20) clang; })
      openssl
      glibc_multi.dev
    ];

    target = "xtensa-esp32-espidf";

    bindgenExtraClangArgs = [ "-include ${pkgs.glibc_multi.dev}/include/features.h" ];

    environmentVariables = {
      CARGO_TARGET_XTENSA_ESP32_ESPIDF_LINKER = "ldproxy";
      CARGO_TARGET_XTENSA_ESP32_ESPIDF_RUNNER = "espflash flash --monitor";
      CARGO_TARGET_XTENSA_ESP32_ESPIDF_RUSTFLAGS = "--cfg espidf_time64";

      CARGO_UNSTABLE_BUILD_STD = "std,panic_abort";

      MCU = "esp32";
      ESP_IDF_VERSION = "v5.4.1";
      # ESP_IDF_SDKCONFIG_DEFAULTS = "${self}/esp32/sdkconfig.defaults";
    };
  };

  attrSetToEnv =
    as:
    pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (name: value: "export ${name}=\"${value}\"") as
    );
in
{
  devShells.esp32 = pkgs.mkShell {
    name = "esp32";

    inherit (buildConfig) nativeBuildInputs;
    inherit (buildConfig) buildInputs;

    shellHook = ''
      export CARGO_BUILD_TARGET="${buildConfig.target}"
      export PATH="${espRustToolchain}/bin:$PATH"
      export ESP_IDF_SDKCONFIG_DEFAULTS="sdkconfig.defaults"
      BINDGEN_EXTRA_CLANG_ARGS="$BINDGEN_EXTRA_CLANG_ARGS ${pkgs.lib.concatStringsSep " " buildConfig.bindgenExtraClangArgs}"

      ${attrSetToEnv buildConfig.environmentVariables}
    '';
  };

  packages.esp32 =
    let
      packageName = "esp32";
    in
    pkgs.rustPlatform.buildRustPackage {
      name = packageName;
      pname = "esp32";
      buildAndTestSubdir = packageName;
      src = ../.;

      cargoDeps = combinedVendoredCargoDeps;

      inherit (buildConfig) nativeBuildInputs;
      inherit (buildConfig) buildInputs;

      configurePhase = ''
        BINDGEN_EXTRA_CLANG_ARGS="$BINDGEN_EXTRA_CLANG_ARGS ${pkgs.lib.concatStringsSep " " buildConfig.bindgenExtraClangArgs}"

        ${attrSetToEnv buildConfig.environmentVariables}

        touch .env
        echo "WIFI_SSID=ssid" >> .env
        echo "WIFI_PASSWORD=password" >> .env
      '';

      buildPhase = ''
        cargo build -j $(nproc) -p ${packageName} --offline --release --target=${buildConfig.target}
      '';

      checkPhase = ''
        cargo clippy --package ${packageName} --all-features --target=${buildConfig.target} -- -W clippy::pedantic -D warnings
        cargo fmt --package ${packageName} --check
      '';

      installPhase = ''
        mkdir -p $out
        cp target/${buildConfig.target}/release/esp32 $out
      '';

      fixupPhase = ''
        echo Skipping fixup phase...
      '';
    };

  apps.esp32 = {
    type = "app";
    meta.description = "flash firmware";
    program = toString (
      pkgs.writeShellScript "flash-firmware" ''
        exec ${pkgs.lib.getExe pkgs.espflash} flash ${self.packages.${system}.esp32}/esp32
      ''
    );
  };
}
