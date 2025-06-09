{ pkgs, lib, ... }: let
  inherit (lib) recurseIntoAttrs;
  inherit (pkgs) callPackage;

  flutterPackages = recurseIntoAttrs (callPackage ./flutter {
    useNixpkgsEngine = false;
  });
  flutterPackages' = recurseIntoAttrs (callPackage ./flutter {
    useNixpkgsEngine = true;
  });
in {
  inherit flutterPackages;
  flutterPackages-bin = flutterPackages;
  flutterPackages-source = flutterPackages';
  default = flutterPackages'.stable;
  flutter = flutterPackages.stable;
  flutter327 = flutterPackages.v3_27;
  flutter329 = flutterPackages.v3_29;
  flutter332 = flutterPackages.v3_32;
}
