#!/bin/bash
set -euo pipefail

PKGNAME="alsa-lib"
PKGVER="1.2.14"
# Note: Verify this SHA256 checksum after first download
SOURCE_ARCHIVE_SHA256="a7bc6c09f0e5a622ebc8afb63a194aa1396145b5c6433d3445363201d96c23c4"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/alsa-project/alsa-lib/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    # Skip on Windows - ALSA is Linux-only
    case "$OS" in
        "WINDOWS")
            echo "Skipping alsa-lib on Windows (Linux-only)"
            return 0
            ;;
    esac

    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    . cross.env

    # ALSA requires autoreconf when building from git archive
    autoreconf -vif

    # ./configure fails to pass LDFLAGS to linker which include -target
    export CC="$CC -target $TARGET_ARCH"

    ./configure \
        --host="${TARGET_ARCH}" \
        --prefix="${OUTPUT_BASE}" \
        --disable-static \
        --enable-shared \
        --disable-python

    make
    make install
}

run "$@"
