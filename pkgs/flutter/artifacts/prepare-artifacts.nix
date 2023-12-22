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

  postPatch = ''
    echo '>>> current platform=${src.platform}'
    echo '>>> Path: ${toString ./overrides/${src.platform}.nix}'
    echo '>>> String: ${ofile}'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -r . "$out/bin/cache"

    runHook postInstall
  '';
}).overrideAttrs (
# The following fails, because the path gets corrupted
  if builtins.pathExists ./overrides/${src.platform}.nix
  then callPackage ./overrides/${src.platform}.nix { }
  else ({ ... }: { })
)
