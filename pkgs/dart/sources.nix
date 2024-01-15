let version = "3.3.0-279.0.dev"; in
{ fetchurl }: {
  versionUsed = version;
  "${version}-x86_64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-macos-x64-release.zip";
    sha256 = "04nna9m8h10f5r49sfb4j8cnxdzq9q32qmv51bf6mj11icvwxjlh";
  };
  "${version}-aarch64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-macos-arm64-release.zip";
    sha256 = "0xabr1kzhpxgpw5bi6sivq220q631aj47zimnws3k7v5zxjd6rl9";
  };
  "${version}-aarch64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-linux-arm64-release.zip";
    sha256 = "05v8gsi7lblhwa0w6fwqj57iqvfq4c2s1qr8h0k59x48zj2fgvsx";
  };
  "${version}-x86_64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-linux-x64-release.zip";
    sha256 = "1h5zn7bmbvkwhq1jqzsl9jy988x0jaj19294zka6m6c0k0p7mq0d";
  };
  "${version}-i686-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-linux-ia32-release.zip";
    sha256 = "0aglaib4jlyzm0zg5sg0v8x01wvkf8zpky05r0hbw6wgsj90wlaf";
  };
}
