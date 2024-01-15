{ lib
, stdenv
, callPackage
, autoPatchelfHook
, src
}:
let
  override = ./overrides + "/${src.flutterPlatform}.nix";
in
(stdenv.mkDerivation {
  inherit (src) name;
  inherit src;

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -r . "$out/bin/cache"

    runHook postInstall
  '';
}).overrideAttrs (
  if builtins.pathExists override
  then callPackage override { }
  else ({ ... }: { })
)
