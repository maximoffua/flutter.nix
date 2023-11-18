{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) recurseIntoAttrs;
  inherit (pkgs) callPackage;

  dart = callPackage ./dart { };
  flutterPackages =
    recurseIntoAttrs (callPackage ./flutter {});
  flutter-unwrapped = flutterPackages.stable;
  flutter = flutterPackages.wrapFlutter flutter-unwrapped;
in {
  inherit dart flutter flutter-unwrapped;
}
