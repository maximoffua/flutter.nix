let version = "3.4.0-140.0.dev"; in
{ fetchurl }: {
  versionUsed = version;
  "${version}-x86_64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-macos-x64-release.zip";
    sha256 = "0jlnm38kxc5gr2q172s5w00wm5jwlsz9pr8dr6lamc4xz5yhr3k5";
  };
  "${version}-aarch64-darwin" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-macos-arm64-release.zip";
    sha256 = "0drk9x2njmprphf97m82x7969q1hnz9gihbzv5532pvc90klj78c";
  };
  "${version}-aarch64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-linux-arm64-release.zip";
    sha256 = "0yw1y98yy4x69cw1jamcs644p48f84iqmsnl6v9hb7j2686drrpx";
  };
  "${version}-x86_64-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-linux-x64-release.zip";
    sha256 = "0l33gmbls4r6nalci3a65mg4rzj9vgy123awqxkbz9kvi8i9vli8";
  };
  "${version}-i686-linux" = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/dev/release/${version}/sdk/dartsdk-linux-ia32-release.zip";
    sha256 = "1waxn6qriw8hmvqxqya1zqmjx24s6lxr8l6gl4gmc28c72rwhsqz";
  };
}
