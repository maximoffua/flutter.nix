#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.pyyaml

import shutil
import json
import urllib.request
import tempfile
from sys import exit
import os
import subprocess
import re
import json
import argparse
import yaml
import json


FLAKE = subprocess.Popen(['git',
                         'rev-parse',
                         '--show-toplevel'],
                        stdout=subprocess.PIPE,
                        text=True).communicate()[0].strip()

NIXPKGS = """import <nixpkgs> {
  overlays = [
    (final: prev: let own = import %s/pkgs { pkgs = prev; lib = prev.lib; };
     in { inherit (own) flutter dart; })
  ];
}
""" % (FLAKE)

def load_code(name, **kwargs):
    with open(f"{FLAKE}/update/{name}", 'r') as f:
        code = f.read()

    for (key, value) in kwargs.items():
        code = code.replace(f"@{key}@", value)

    return code


# Return out paths
def nix_build(code):
    temp = tempfile.NamedTemporaryFile(mode='w')
    temp.write(code)
    temp.flush()
    os.fsync(temp.fileno())

    process = subprocess.Popen(
        [
            "nix",
            "build",
            "--impure",
            "--print-out-paths",
            "--no-link",
            "--inputs-from", FLAKE, "-I", "nixpkgs=flake:nixpkgs",
            "--experimental-features", "nix-command flakes",
            "--expr",
            f"with {NIXPKGS}; callPackage {temp.name} {{}}"],
        stdout=subprocess.PIPE,
        text=True)

    process.wait()
    temp.close()
    return process.stdout.read().strip().splitlines()[0]


# Return errors
def nix_build_to_fail(code):
    temp = tempfile.NamedTemporaryFile(mode='w')
    temp.write(code)
    temp.flush()
    os.fsync(temp.fileno())

    process = subprocess.Popen(
        [
            "nix",
            "build",
            "--impure",
            "--keep-going",
            "--no-link",
            "--inputs-from", FLAKE, "-I", "nixpkgs=flake:nixpkgs",
            "--experimental-features", "nix-command flakes",
            "--expr",
            f"with {NIXPKGS}; callPackage {temp.name} {{}}"],
        stderr=subprocess.PIPE,
        text=True)

    stderr = ""
    while True:
        line = process.stderr.readline()
        if not line:
            break
        stderr += line
        print(line.strip())

    process.wait()
    temp.close()
    return stderr


def get_artifact_hashes(flutter_compact_version):
    code = load_code("get-artifact-hashes.nix",
                     nixpkgs_root=FLAKE,
                     flutter_compact_version=flutter_compact_version)

    stderr = nix_build_to_fail(code)

    pattern = re.compile(
        r"/nix/store/.*-flutter-artifacts-(.+?)-(.+?).drv':\n\s+specified: .*\n\s+got:\s+(.+?)\n")
    matches = pattern.findall(stderr)
    result_dict = {}

    for match in matches:
        flutter_platform, architecture, got = match
        result_dict.setdefault(flutter_platform, {})[architecture] = got

    def sort_dict_recursive(d):
        return {
            k: sort_dict_recursive(v) if isinstance(
                v, dict) else v for k, v in sorted(
                d.items())}
    result_dict = sort_dict_recursive(result_dict)

    return result_dict


def update_dart(dartVersion):
    process = subprocess.Popen(
        [f"{FLAKE}/pkgs/dart/update.sh", dartVersion],
        stdout=subprocess.PIPE,
        text=None
    )


def get_flutter_hash_and_src(flutter_version):
    code = load_code(
        "get-flutter.nix",
        flutter_version=flutter_version,
        hash="")

    stderr = nix_build_to_fail(code)
    pattern = re.compile(r"got:\s+(.+?)\n")
    hash = pattern.findall(stderr)[0]

    code = load_code(
        "get-flutter.nix",
        flutter_version=flutter_version,
        hash=hash)

    return (hash, nix_build(code))


def write_data(
        sources_dir,
        flutter_version,
        engine_hash,
        dart_version,
        flutter_hash,
        artifact_hashes,
        pubspec_lock):
    with open(f"{sources_dir}/data.json", "w") as f:
        f.write(json.dumps({
            "version": flutter_version,
            "engineVersion": engine_hash,
            "dartVersion": dart_version,
            "flutterHash": flutter_hash,
            "artifactHashes": artifact_hashes,
            "pubspecLock": pubspec_lock,
        }, indent=2).strip() + "\n")


def get_pubspec_lock(flutter_compact_version, flutter_src):
    code = load_code(
        "get-pubspec-lock.nix",
        flutter_compact_version=flutter_compact_version,
        flutter_src=flutter_src)

    stderr = nix_build_to_fail(code)

    pattern = re.compile(r"For full logs, run '+(.+?)'\.\n")
    log_command = pattern.findall(stderr)[0]

    log_process = subprocess.Popen(
        log_command.split(' '),
        stdout=subprocess.PIPE,
        text=True
    )

    log, _ = log_process.communicate()

    pattern = re.compile(
        r'----------------\n(.+?)\n----------------', re.DOTALL)
    pubspec_lock_yaml = pattern.findall(log)[0]

    return yaml.safe_load(pubspec_lock_yaml)


# Finds Flutter version, Dart version, and Engine hash.
# If the Flutter version is given, it uses that. Otherwise finds the
# latest stable Flutter version.
def find_versions(flutter_version=None):
    engine_hash = None
    dart_version = None

    releases = json.load(urllib.request.urlopen(
        "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"))

    if not flutter_version:
        stable_hash = releases['current_release']['stable']
        release = next(
            filter(
                lambda release: release['hash'] == stable_hash,
                releases['releases']))
        flutter_version = release['version']

    tags = subprocess.Popen(['git',
                             'ls-remote',
                             '--tags',
                             'https://github.com/flutter/engine.git'],
                            stdout=subprocess.PIPE,
                            text=True).communicate()[0].strip()

    try:
        engine_hash = next(
            filter(
                lambda line: line.endswith(f'refs/tags/{flutter_version}'),
                tags.splitlines())).split('refs')[0].strip()
    except StopIteration:
        exit(
            f"Couldn't find Engine hash for Flutter version: {flutter_version}")

    try:
        dart_version = next(
            filter(
                lambda release: release['version'] == flutter_version,
                releases['releases']))['dart_sdk_version']
    except StopIteration:
        exit(
            f"Couldn't find Dart version for Flutter version: {flutter_version}")

    return (flutter_version, engine_hash, dart_version)


def main():
    parser = argparse.ArgumentParser(description='Update Flutter in Nixpkgs')
    parser.add_argument('--version', type=str, help='Specify Flutter version')
    parser.add_argument('--artifact-hashes', action='store_true',
                        help='Whether to get artifact hashes')
    args = parser.parse_args()

    (flutter_version, engine_hash, dart_version) = find_versions(args.version)

    flutter_compact_version = '_'.join(flutter_version.split('.')[:2])

    sources_dir = f"{FLAKE}/pkgs/flutter/sources"
    info = {}
    try:
        info = json.load(open(f"{sources_dir}/data.json"))
    except FileNotFoundError:
        ...

    if args.artifact_hashes:
        print(get_artifact_hashes(flutter_compact_version))
        return

    print(f"Flutter version: {flutter_version} ({flutter_compact_version})")
    print(f"Engine hash: {engine_hash}")
    print(f"Dart version: {dart_version}")

    update_dart(dart_version)
    (flutter_hash, flutter_src) = get_flutter_hash_and_src(flutter_version)

    common_data_args = {
        "sources_dir": sources_dir,
        "flutter_version": flutter_version,
        "dart_version": dart_version,
        "engine_hash": engine_hash,
        "flutter_hash": flutter_hash,
    }

    if info.get('version', '') == flutter_version:
        print(f"Flutter package is already up to date: v{info['version']}")
    else:
        shutil.rmtree(sources_dir, ignore_errors=True)
        os.makedirs(sources_dir)
        write_data(
            pubspec_lock={},
            artifact_hashes={},
            **common_data_args)
    if not info.get('pubspec_lock', {}):
        pubspec_lock = get_pubspec_lock(flutter_compact_version, flutter_src)
        write_data(
            pubspec_lock=pubspec_lock,
            artifact_hashes={},
            **common_data_args)

    if not info.get('artifact_hashes', {}):
        artifact_hashes = get_artifact_hashes(flutter_compact_version)
        write_data(
            pubspec_lock=pubspec_lock,
            artifact_hashes=artifact_hashes,
            **common_data_args)


if __name__ == "__main__":
    main()
