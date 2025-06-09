{
  description = "Flutter SDK in a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
      imports = [
        flake-parts.flakeModules.easyOverlay
        ./packages/flake-module.nix
      ];

      perSystem = { config, self', inputs', pkgs, system, lib, ... }: let
        mkApp = name: let
          pkg = self'.packages.${name};
        in {
          type = "app";
          program = "${pkg}/bin/${name}";
        };
      in {
        overlayAttrs = {
          inherit (self'.packages) flutter flutter327 flutter329 flutter332
            flutterPackages flutterPackages-bin flutterPackages-source;
        };

        apps = rec {
          flutter = mkApp "flutter";
          dart = mkApp "dart";
          default = flutter;
        };

        checks.test = pkgs.stdenvNoCC.mkDerivation {
          name = "flutter-doctor";
          src = ./.;
          nativeBuildInputs = [self'.packages.flutter];
          dontBuild = true;
          installPhase = ''
            mkdir $out
          '';
          checkPhase = ''
            flutter doctor -v
          '';
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            (pkgs.python311Full.withPackages (pip: [
              pip.pyaml
            ]))
          ];
        };
      };

      flake = {};
    };
}
