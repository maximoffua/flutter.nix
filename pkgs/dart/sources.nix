let version = "3.4.3"; in
{ fetchurl }: {
  versionUsed = version;
  "${version}-x86_64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-macos-x64-release.zip";
    sha256 = "1zm7da40q10abm1xyq0ayhwnb7yskq67ib4y5mhci8h52i7xziyk";
  };
  "${version}-aarch64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-macos-arm64-release.zip";
    sha256 = "0jiyjbdjn2djgcf3l4q9inwqdwmbb6xh258wm6p1aw2fn6m2872l";
  };
  "${version}-aarch64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-arm64-release.zip";
    sha256 = "0xnmkgqn4z3qa6s6pr0p41k57qlfg5000q749ph0ygcsy39fcmf1";
  };
  "${version}-x86_64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-x64-release.zip";
    sha256 = "18ycdvxwinshmfc7wm3s1iq8z5w1n4svpnf0a3aa09vd92aawrk3";
  };
  "${version}-i686-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-linux-ia32-release.zip";
    sha256 = "1scb9kxmiw7g6mgklr789r4hgmibycfzcjjk2z284sn5c74v7ch6";
  };
}
