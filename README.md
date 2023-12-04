# Flutter SDK for Nix

This repository is made for fixing issues with flutter in nixpkgs, specifically [#260278](https://github.com/NixOS/nixpkgs/issues/260278).

# Getting started

This flake provides the following packages:

- packages.${system}.flutter
- packages.${system}.dart
- packages.${system}.flutter-unwrapped

Will add overlays later.

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

If you don't want to use overlays, just use package directly from this flake:

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
