#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

set -euo pipefail

# so if the script fails, debug logs are on stderr
log() {
  >&2 echo "DART_UPDATER: $@"
}

latest_version() {
  local channel=${1:-stable}
  local NEW_VER_DETAILS=$(curl -sL https://storage.googleapis.com/dart-archive/channels/$channel/release/latest/VERSION)
  jq -r '.version' <<< "$NEW_VER_DETAILS"
}

NEW_VER=${1:-""}
CHANNEL=${CHANNEL:-${FLUTTER_CHANNEL:-stable}}
if [[ -z $NEW_VER ]]; then
  # fetch the latest version number from upstream
  NEW_VER=$(latest_version $CHANNEL)
fi

MY_PATH=$(dirname $(realpath "$0"))
SRC_FILE=$(mktemp)

CURRENT_VER=$(awk '/version = /{print $4}' $MY_PATH/sources.nix | tr -d \"\;)
if [[ $CURRENT_VER = $NEW_VER ]]; then
  log "aleready up to date: $CURRENT_VER = $NEW_VER"
  rm $SRC_FILE
  exit 0
fi

log "file to write is $SRC_FILE"

if ! curl -sL https://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/$NEW_VER/VERSION; then
  NEW_VER=$(latest_version ${FLUTTER_CHANNEL:-beta})
  CHANNEL=${FLUTTER_CHANNEL:-beta}
  log "Using $CHANNEL $NEW_VER"
fi

PRELUDE="let version = \"$NEW_VER\"; in
{ fetchurl }: {
  versionUsed = version;"
echo "$PRELUDE" > "$SRC_FILE"
log "wrote prelude"

# Fetches the source, then  writes the fetcher and hash into the sources file.
# Arguments:
#   - $1: VARIABLE NAME of (table of nix platform -> dart platform mappings) ("DARWIN_PLATFORMS"|"LIN_PLATFORMS")
#   - $2: Dart-OS ("macos"|"linux")
write_for_platform() {
  BASE_OF_ALL_URLS="https://storage.googleapis.com/dart-archive/channels/$CHANNEL/release"
  BASE_URL_WRITTEN="$BASE_OF_ALL_URLS/\${version}/sdk"
  BASE_URL_FETCHED="$BASE_OF_ALL_URLS/$NEW_VER/sdk"

  TABLE_NAME=$1
  declare -n TABLE=$TABLE_NAME

  for platform in "${!TABLE[@]}"; do
    DART_PLATFORM="${TABLE[$platform]}"
    log "trying for dartplatform $DART_PLATFORM (platform $platform) (OS $2)"

    URL_POSTFIX="dartsdk-$2-$DART_PLATFORM-release.zip"
    URL="$BASE_URL_FETCHED/$URL_POSTFIX"
    log "URL for $DART_PLATFORM: $URL"

    HASH=$(nix-prefetch-url "$URL" --type sha256)
    log "hash for platform $platform: $HASH"

    FETCHER="  \"\${version}-$platform\" = fetchurl {
    url = \"$BASE_URL_WRITTEN/$URL_POSTFIX\";
    sha256 = \"$HASH\";
  };"

    echo "$FETCHER" >> $SRC_FILE
  done
  log "finished for $1"

}

# Map nix platforms -> Dart platforms
X8664="x64"
AARCH64="arm64"
I686="ia32"
declare -A DARWIN_PLATFORMS=(["aarch64-darwin"]="$AARCH64"
        ["x86_64-darwin"]="$X8664")

declare -A LIN_PLATFORMS=( ["x86_64-linux"]="$X8664"
        ["i686-linux"]="$I686"
        ["aarch64-linux"]="$AARCH64")

write_for_platform "DARWIN_PLATFORMS" "macos"
write_for_platform "LIN_PLATFORMS" "linux"

echo '}' >> $SRC_FILE

log "moving tempfile to target directory"
mv "$SRC_FILE" "$MY_PATH/sources.nix"
