{...}:

{
  perSystem = {pkgs, self', ...}: {
    packages = {
      dart = pkgs.callPackage ./dart {};
      engine = pkgs.callPackage ./engine {};
      flutter = pkgs.callPackage ./flutter {
        dart = self'.packages.dart;
      };
    };
  };
}
