{...}: let
  data = builtins.fromJSON (builtins.readFile ../versionInfo.json);
in {
  perSystem = { pkgs, self', ... }: let
    flutterPackages = pkgs.callPackage ./flutter {
      inherit (self'.packages) dart engine;
      inherit (data) artifactHashes pubspecLock channel version flutterHash;
    };
  in {
    packages = {
      inherit (flutterPackages) flutter-bin flutter-sources;
      flutter = flutterPackages.flutter-bin;
      dart = pkgs.callPackage ./dart {
        version = data.dartVersion;
        sources = {
          "${data.dartVersion}-x86_64-linux" = pkgs.fetchzip {
            url = "https://storage.googleapis.com/dart-archive/channels/${data.channel}/release/${data.dartVersion}/sdk/dartsdk-linux-x64-release.zip";
            sha256 = data.dartHash.x86_64-linux;
          };
          "${data.dartVersion}-aarch64-linux" = pkgs.fetchzip {
            url = "https://storage.googleapis.com/dart-archive/channels/${data.channel}/release/${data.dartVersion}/sdk/dartsdk-linux-arm64-release.zip";
            sha256 = data.dartHash.aarch64-linux;
          };
          "${data.dartVersion}-x86_64-darwin" = pkgs.fetchzip {
            url = "https://storage.googleapis.com/dart-archive/channels/${data.channel}/release/${data.dartVersion}/sdk/dartsdk-macos-x64-release.zip";
            sha256 = data.dartHash.x86_64-darwin;
          };
          "${data.dartVersion}-aarch64-darwin" = pkgs.fetchzip {
            url = "https://storage.googleapis.com/dart-archive/channels/${data.channel}/release/${data.dartVersion}/sdk/dartsdk-macos-arm64-release.zip";
            sha256 = data.dartHash.aarch64-darwin;
          };
        };
      };
      engine = pkgs.callPackage ./engine {
        version = data.engineVersion;
        hashes = data.engineHashes;
        swiftshaderHash = data.engineSwiftShaderHash;
        swiftshaderRev = data.engineSwiftShaderRev;
        flutterVersion = data.version;
        dart = self'.packages.dart;
      };
    };
  };
}
