#!/bin/bash
set -euo pipefail

PKGNAME="libiconv"
PKGVER="1.18"
SOURCE_ARCHIVE_SHA256="3b08f5f4f9b4eb82f151a7040bfd6fe6c6fb922efe4b1659c66ea933276965e8"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://ftpmirror.gnu.org/libiconv/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Set up environment for cross-compilation
    generate_cross_env
    . cross.env

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-nls \
        --disable-shared \
        --enable-extra-encodings

    make -j$(nproc)
    make install
}

run "$@"
