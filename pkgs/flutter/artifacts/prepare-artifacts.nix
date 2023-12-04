{ lib
, stdenv
, callPackage
, autoPatchelfHook
, src
, gtk3
, glib
, fontconfig
}:

(stdenv.mkDerivation {
  inherit (src) name;
  inherit src;

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs = [glib fontconfig gtk3];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -r . "$out/bin/cache"

    runHook postInstall
  '';
}).overrideAttrs (
  if builtins.pathExists ./overrides/${src.platform}.nix
  then callPackage ./overrides/${src.platform}.nix { }
  else ({ ... }: { })
)
