{ callPackage, fetchzip, fetchFromGitHub, buildDartApplication, dart, lib, stdenv }:
let
  mkCustomFlutter = args: callPackage ./flutter.nix args;
  wrapFlutter = flutter: callPackage ./wrapper.nix { inherit flutter; };
  getPatches = dir:
    let files = builtins.attrNames (builtins.readDir dir);
    in if (builtins.pathExists dir) then map (f: dir + ("/" + f)) files else [ ];
  mkFlutter =
    { version
    , engineVersion
    , dartVersion
    , flutterHash
    , patches
    , pubspecLock
    , artifactHashes
    , ...
    }:
      assert lib.asserts.assertMsg (lib.strings.hasPrefix dartVersion dart.version)
        ''Dart version mismatch: (pkgs) ${builtins.toString dart.version} != ${dartVersion} (required)
          Hint: run `pkgs/dart/update.sh <version>` to fetch required version.'';
    let
      args = {
        inherit dart buildDartApplication;
        inherit version engineVersion patches pubspecLock artifactHashes;
        src = fetchFromGitHub {
          owner = "flutter";
          repo = "flutter";
          rev = version;
          hash = flutterHash;
        };
      };
    in
    (mkCustomFlutter args).overrideAttrs (prev: next: {
      passthru = next.passthru // rec {
        inherit wrapFlutter mkCustomFlutter mkFlutter;
        buildFlutterApplication = callPackage ../build-support/flutter {
          # Package a minimal version of Flutter that only uses Linux desktop release artifacts.
          flutter = (wrapFlutter (mkCustomFlutter args)).override {
            supportedTargetFlutterPlatforms = [ "universal" "linux" ];
          };
        };
      };
    });

  data = lib.importJSON (./sources + "/data.json");
in
{
  inherit wrapFlutter mkFlutter;
  unwrapped = mkFlutter ({
    patches = getPatches ./patches;
  } // data);
}
