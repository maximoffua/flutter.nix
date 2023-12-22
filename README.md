# Flutter SDK for Nix

This repository is made for fixing issues with flutter in nixpkgs, specifically [#260278](https://github.com/NixOS/nixpkgs/issues/260278).

Big thanks:
- [hacker1024](https://github.com/hacker1024/nixpkgs/tree/feature/flutter-from-source) for his Nix derivation for Flutter
- [Fructokinase](https://github.com/Fructokinase/nixpkgs/tree/flutter) for Gradle/Android patches
- [FlafyDev](https://github.com/NixOS/nixpkgs/pull/262789#issuecomment-1853882072) for comments

# Getting started

This flake provides the following packages:

- `packages.${system}.flutter`
- `packages.${system}.dart`
- `packages.${system}.flutter-unwrapped`

and an overlay:

- `overlays.default`

## With [devenv](https://devenv.sh) and overlays

> There might be an issue with overlay is not applied properly

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

There is a nix script for trying to download artifacts and calculate their hash sums:

```sh
nix build --keep-going --impure -L --expr 'import ./try-prefetch.nix'
```
