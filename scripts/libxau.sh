#!/bin/bash
set -euo pipefail

PKGNAME="libXau"
PKGVER="1.0.11"
SOURCE_ARCHIVE_SHA256="f3fa3282f5570c3f6bd620244438dbfbdd580fc80f02f549587a0f8ab329bbeb"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/lib/libXau-${PKGVER}.tar.xz"
}

build() {
    # Linux-only
    if [[ "$OS" != "LINUX" ]]; then
        echo "Skipping libXau (Linux-only)"
        return 0
    fi

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
        --enable-shared \
        --disable-static

    make
    make install
}

run "$@"
