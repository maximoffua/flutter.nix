{ dart
, stdenv
, cacert
,
}:
stdenv.mkDerivation {
  name = "pubspec-lock";
  src = @flutter_src@;

  nativeBuildInputs = [ dart ];

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "";

  buildPhase = ''
    cd ./packages/flutter_tools

    export HOME="$(mktemp -d)"
    dart --root-certs-file=${cacert}/etc/ssl/certs/ca-bundle.crt pub get -v

    echo ----------------
    cat ./pubspec.lock
    echo ----------------

    exit 1
  '';
}
