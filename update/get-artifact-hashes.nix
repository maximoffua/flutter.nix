{ callPackage
, flutter
, lib
, symlinkJoin
,
}:
let
  flake = "@nixpkgs_root@";
  flutterPlatforms = [
    "android"
    "ios"
    "web"
    "linux"
    "windows"
    "macos"
    "fuchsia"
    "universal"
  ];
  systemPlatforms = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
  ];

  derivations =
    lib.foldl'
      (
        acc: flutterPlatform:
          acc
          ++ (map
            (systemPlatform:
              callPackage "${flake}/pkgs/flutter/artifacts/fetch-artifacts.nix" {
                inherit flutter;
                inherit flutterPlatform;
                inherit systemPlatform;
                hash = "";
              })
            systemPlatforms)
      ) [ ]
      flutterPlatforms;
in
symlinkJoin {
  name = "evaluate-derivations";
  paths = derivations;
}

