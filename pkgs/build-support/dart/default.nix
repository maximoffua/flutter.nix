{callPackage, recurseIntoAttrs }: let
  pub2nix = recurseIntoAttrs (callPackage ./pub2nix { });
  fetchDartDeps = callPackage ./fetch-dart-deps {};
  dartHooks = callPackage ./build-dart-application/hooks {};
  buildDartApplication = callPackage ./build-dart-application { inherit pub2nix dartHooks; };
in {
  inherit buildDartApplication fetchDartDeps pub2nix;
}
