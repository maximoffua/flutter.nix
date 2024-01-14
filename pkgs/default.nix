{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) recurseIntoAttrs;
  inherit (pkgs) callPackage;
  support =
    recurseIntoAttrs (callPackage ./build-support/dart {})
    // (callPackage ./build-support/flutter {});

  dart = callPackage ./dart {};

  flutterPackages = recurseIntoAttrs (callPackage ./flutter {
    inherit (support) buildDartApplication;
    inherit dart;
  });
  flutter-unwrapped = flutterPackages.unwrapped;
  flutter = flutterPackages.wrapFlutter flutter-unwrapped;
in {
  inherit dart flutter flutter-unwrapped;
  inherit (support) buildDartApplication buildFlutterApplication pub2nix dartHooks;
  default = flutter;
}
