#!/bin/bash
set -euo pipefail

PKGNAME="speex"
PKGVER="1.2.1"
SOURCE_ARCHIVE_SHA256="4b44d4f2b38a370a2d98a78329fefc56a0cf93d1c1be70029217baae6628feea"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "http://downloads.xiph.org/releases/speex/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    . cross.env

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-shared \
        --enable-static \
        --disable-binaries \
        --enable-sse

    make
    make install

    # Rename .lib to .a for compatibility with lld linker
    mv "${OUTPUT_BASE}/lib/libspeex.lib" "${OUTPUT_BASE}/lib/libspeex.a"
}

run "$@"
