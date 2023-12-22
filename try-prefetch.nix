{pkgs ? import <nixpkgs> {}}:
  let
  own = import ./pkgs {inherit pkgs; lib = pkgs.lib;};
  flutter = own.flutter;
  in
pkgs.callPackage (
  {
    callPackage,
    lib,
    symlinkJoin,
  }: let
    flutterPlatforms = [
      # "android"
      # "ios"
      # "web"
      "linux"
      # "windows"
      # "macos"
      # "fuchsia"
      # "universal"
    ];
    archPlatforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      # "aarch64-darwin"
    ];

    # After packaging a new flutter version, put it here.
    # newFlutter = flutter;

    derivations =
      lib.foldl' (
        acc: flutterPlatform:
          acc
          ++ (map (archPlatform:
            callPackage ./pkgs/flutter/artifacts/fetch-artifacts.nix {
              platform = flutterPlatform;
              inherit archPlatform flutter;
              hash = "";
            })
          archPlatforms)
      ) []
      flutterPlatforms;
  in
    # Only way I found to bulid multiple derivations...
    symlinkJoin {
      name = "evaluate-derivations";
      paths = derivations;
    }
) {}
