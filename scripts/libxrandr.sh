#!/bin/bash
set -euo pipefail

PKGNAME="libXrandr"
PKGVER="1.5.4"
SOURCE_ARCHIVE_SHA256="1ad5b065375f4a85915aa60611cc6407c060492a214d7f9daf214be752c3b4d3"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/lib/libXrandr-${PKGVER}.tar.xz"
}

build() {
    # Skip on Windows
    case "$OS" in
        "WINDOWS")
            echo "Skipping libXrandr on Windows"
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
