{ lib
, stdenv
, callPackage
, autoPatchelfHook
, src
}:
let
 ofile = (builtins.toString ./overrides) + "/${src.platform}.nix";
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
  if builtins.pathExists ofile
  then callPackage ofile { }
  else ({ ... }: { })
)
