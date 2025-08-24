{
  callPackage,
  fetchFromGitHub,
  dart,

  version,
  channel,
  engine,
  # engineVersion,
  pubspecLock,
  artifactHashes,
  flutterHash,
}:
let
  mkCustomFlutter = args: callPackage ./flutter.nix args;
  wrapFlutter = flutter: callPackage ./wrapper.nix { inherit flutter; };
  getPatches = dir: let
    files = builtins.attrNames (builtins.readDir dir);
  in
  if (builtins.pathExists dir) then map (f: dir + ("/" + f)) files else [ ];
  mkFlutter =
    {
      engineVersion,
      patches,
      engine ? null,
      useNixpkgsEngine ? false,
    }:
    let
      args = {
        inherit
          version
          engineVersion
          patches
          pubspecLock
          artifactHashes
          useNixpkgsEngine
          channel
          engine
          dart
          ;

        src = fetchFromGitHub {
          owner = "flutter";
          repo = "flutter";
          rev = version;
          hash = flutterHash;
        };
      };
    in
    (mkCustomFlutter args).overrideAttrs (
      prev: next: {
        passthru = next.passthru // rec {
          inherit wrapFlutter mkCustomFlutter mkFlutter;
          buildFlutterApplication = callPackage ./build-support/build-flutter-application.nix {
            flutter = wrapFlutter (mkCustomFlutter args);
          };
        };
      }
    );
in {
  inherit mkFlutter wrapFlutter mkCustomFlutter;
  flutter-bin = wrapFlutter (mkFlutter {
    patches = getPatches ./patches;
    engineVersion = engine.version;
    engine = null;
  });
  flutter-sources = wrapFlutter (mkFlutter {
    patches = getPatches ./patches;

    useNixpkgsEngine = true;
    engine = engine;
    engineVersion = engine.version;
  });
}
