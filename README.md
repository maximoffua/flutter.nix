[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/maximoffua/flutter.nix/badge)](https://flakehub.com/flake/maximoffua/flutter.nix)

# Flutter SDK for Nix

This repository is made for fixing issues with flutter in nixpkgs, specifically [#260278](https://github.com/NixOS/nixpkgs/issues/260278).

> [!IMPORTANT]
> [nixpkgs](https://github.com/NixOS/nixpkgs/pull/336650) has already packaged latest Flutter version, which works well. This makes this repository obsolate.

# Getting started

This flake provides the following packages:

- `packages.${system}.flutter`
- `packages.${system}.dart`

and an overlay:

- `overlays.default`

There is also binary cache hosted by [Cachix](https://mtech.cachix.org):

https://mtech.cachix.org  
`mtech.cachix.org-1:cPDMKB6bI2DjpXfsE8dOcYOdaas9afdRNhLA0MEfXuo=`

## With flakes

Add this flake as an input and either use:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flutter-nix.url = "github:maximoffua/flutter.nix/stable"; # remove `/stable` to use main branch
          # stable can be replaced with specific tag matching Flutter versions, e.g. 3.16.7
  };
 
  outputs = { self, flutter-nix }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      # add overlay from flutter-nix, which replaces dart and flutter packages
      overlays = [
        flutter-nix.overlays.default
      ];
    };
  in {
    # Use flutter-nix in your outputs or use `pkgs`,
    # which is nixpkgs for the system, with flutter.nix's overlay applied.

    packages.flutter = flutter-nix.packages.${system}.flutter;
  };
}
```

See #1 for more examples of usage with flakes.

## With [devenv](https://devenv.sh) and overlays

```yaml
# devenv.yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixpkgs-unstable
  flutter-nix:
    url: github:maximoffua/flutter.nix/stable
    overlays:
      - default
```

```nix
# devenv.nix
{
  pkgs,
  inputs,
  ...
}: {
  languages.dart.enable = true;
  languages.dart.package = pkgs.flutter;

  enterShell = ''
    flutter --version
  '';
}
```

## With [devenv](https://devenv.sh)

If you have issues with overlay, just use package directly from this flake:

```yaml
# devenv.yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixpkgs-unstable
  flutter-nix:
    url: github:maximoffua/flutter.nix/stable
```

```nix
# devenv.nix
{
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.system;
  flutter = inputs.flutter-nix.packages.${system}.flutter;
in {
  languages.dart.enable = true;
  languages.dart.package = flutter;

  enterShell = ''
    flutter --version
  '';
}
```

## Update version

There is a Python script which will obtain the latest Flutter version, fetch info and update hash sums.

```sh
./update/update.py
```

## Contributors

Big thanks:

- [hacker1024](https://github.com/hacker1024/nixpkgs/tree/feature/flutter-from-source) for his Nix derivation for Flutter
- [Fructokinase](https://github.com/Fructokinase/nixpkgs/tree/flutter) for Gradle/Android patches
- [FlafyDev](https://github.com/NixOS/nixpkgs/pull/262789#issuecomment-1853882072) for comments

