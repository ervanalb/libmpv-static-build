#!/bin/bash
set -euo pipefail

PKGNAME="libXrender"
PKGVER="0.9.11"
SOURCE_ARCHIVE_SHA256="6aec3ca02e4273a8cbabf811ff22106f641438eb194a12c0ae93c7e08474b667"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/lib/libXrender-${PKGVER}.tar.gz"
}

build() {
    # Skip on Windows
    case "$OS" in
        "WINDOWS")
            echo "Skipping libXrender on Windows"
            return 0
            ;;
    esac

    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    . cross.env

    # ./configure fails to pass LDFLAGS to linker which include -target
    export CC="$CC -target $TARGET_ARCH"

    ./configure \
        --host="${TARGET_ARCH}" \
        --prefix="${OUTPUT_BASE}" \
        --disable-static \
        --enable-shared \
        --disable-malloc0returnsnull

    make
    make install
}

run "$@"
