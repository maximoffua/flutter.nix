{
  description = "Flutter SDK in a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, nixpkgs, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        flake-parts.flakeModules.easyOverlay
      ];
      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        lib,
        ...
      }: {
        packages = let
          own = import ./pkgs {inherit pkgs lib;};
        in {
          inherit (own) flutter dart flutter-unwrapped;
          default = own.flutter;
        };

        apps = let
          mkApp = name: let pkg = self'.packages.${name}; in {
            type = "app";
            program = "${pkg}/bin/${name}";
          };
        in rec {
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
            flutter doctor
          '';
        };
      };
      flake = {};
    };
}
