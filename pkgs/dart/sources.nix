let version = "3.4.1"; in
{ fetchurl }: {
  versionUsed = version;
  "${version}-x86_64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-macos-x64-release.zip";
    sha256 = "1617bv5p0y4v6bva34qbimz01syrz4n3l1vp7r69j4sv0chqcx66";
  };
  "${version}-aarch64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-macos-arm64-release.zip";
    sha256 = "0xd5p4fs6hfmp1djd3d95pkpcn6rhqqnqdq1kpczj0ysd5i6xb02";
  };
  "${version}-aarch64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-arm64-release.zip";
    sha256 = "1a43jf6x0ir7glm4m72ryh8g3k24l6jn9qxxj23b3d9yxjq7bg44";
  };
  "${version}-x86_64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-x64-release.zip";
    sha256 = "0hni54h9ds48jxi172zqgfp32ri0i2966kmqx6q5i6ynr0yqs1yi";
  };
  "${version}-i686-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-ia32-release.zip";
    sha256 = "1d4v64qdd96f917mpdbb51iyhhxf37c89pvvkqhj7l9s5ns59qhv";
  };
}
