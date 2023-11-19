{callPackage}: let
  fetchDartDeps = callPackage ./fetch-dart-deps {};
  buildDartApplication = callPackage ./build-dart-application { inherit fetchDartDeps; };
in {
  inherit buildDartApplication fetchDartDeps;
}
