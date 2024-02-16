let version = "3.2.5"; in
{ fetchurl }: {
  versionUsed = version;
  "${version}-x86_64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-macos-x64-release.zip";
    sha256 = "0jfkf74sfms5hjsxq5r9bdjxgs08liig4xk9ln74291l3qrr2j7c";
  };
  "${version}-aarch64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-macos-arm64-release.zip";
    sha256 = "0lkbxb5jd19a1ia383w05f3rsgzfqka0xkl6b4f2cgj0h1hgj652";
  };
  "${version}-aarch64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-arm64-release.zip";
    sha256 = "14zkmvciwdpbyz1y587nrx2a2m5jb61vwj531k52dz4hbrhhm15a";
  };
  "${version}-x86_64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-x64-release.zip";
    sha256 = "1c8a84kdyg00211lkm5bnqjjjwc1pv7gj9zw16wiwlazrgv6cpp3";
  };
  "${version}-i686-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-ia32-release.zip";
    sha256 = "0q1z4bvmwijcgs4ls5i9a6mfnl2xh2scpv7wr54z877h01mypps2";
  };
}
