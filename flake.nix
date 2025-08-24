{
  description = "Flutter SDK in a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
      imports = [
        flake-parts.flakeModules.easyOverlay
        ./packages/flake-module.nix
      ];

      perSystem = { config, self', inputs', pkgs, system, lib, ... }: let
        mkApp = name: let
          pkg = self'.packages.${name};
        in {
          type = "app";
          program = "${pkg}/bin/${name}";
          inherit (pkg) meta;
        };
      in {
        overlayAttrs = {
          inherit (self'.packages) flutter dart engine;
        };

        packages = let
          pkgs = (import nixpkgs {inherit system; config.allowUnfree = true; });
        in {
          test-app = pkgs.callPackage ./test {
            inherit (self'.packages) flutter dart;
          };
        };

        apps = rec {
          flutter = mkApp "flutter";
          dart = mkApp "dart";
          default = flutter;
        };

        checks.test = pkgs.stdenvNoCC.mkDerivation {
          name = "flutter-doctor";
          src = ./.;
          nativeBuildInputs = [self'.packages.flutter];
          dontBuild = true;
          installPhase = ''
            mkdir $out
          '';
          checkPhase = ''
            flutter doctor -v
          '';
        };
        checks.app = self'.packages.test-app;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            (pkgs.python311Full.withPackages (pip: [
              pip.pyaml
            ]))
          ];
        };
        devShells.test = let
          pkgs' = (import nixpkgs {inherit system; config.allowUnfree = true; });
          androidEnvModule = pkgs'.callPackage "${toString pkgs.path}/pkgs/development/mobile/androidenv";
          androidEnvArgs = {
            pkgs = pkgs';
            licenseAccepted = true;
          }
          // lib.optionalAttrs (builtins.hasAttr "config" (builtins.functionArgs androidEnvModule)) {
            config = { };
          };
          androidEnv = androidEnvModule androidEnvArgs;
          sdkArgs = {
            cmdLineToolsVersion = "11.0";
            toolsVersion = "26.1.1";
            platformToolsVersion = ["34.0.4"];
            buildToolsVersions = [ "34.0.0" "30.0.3" ];
            includeEmulator = false;
            platformVersions = ["32" "35"];
            includeSources = false;
            includeSystemImages = false;
            cmakeVersions = ["3.22.1"];
            includeNDK = true;
            ndkVersions = ["26.3.11579264"];
            useGoogleAPIs = true;
            includeExtras = ["extras;google;gcm"];
            extraLicenses = [
              "android-sdk-preview-license"
              "android-googletv-license"
              "android-sdk-arm-dbt-license"
              "google-gdk-license"
              "intel-android-extra-license"
              "intel-android-sysimage-license"
              "mips-android-sysimage-license"
            ];
          };
          androidComposition = androidEnv.composeAndroidPackages sdkArgs;
          androidSdk = androidComposition.androidsdk;
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          inherit (self'.packages) dart flutter;
        in pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.jdk17
            androidSdk
            dart
            flutter
          ];

          inherit ANDROID_HOME;
          ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
          # override the aapt2 binary that gradle uses with the patched one from the sdk
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${lib.head sdkArgs.buildToolsVersions}/aapt2";
          # FLUTTER_ROOT = flutter;
          # DART_ROOT = "${flutter}/bin/cache/dart-sdk";
        };
      };

      flake = {};
    };
}
