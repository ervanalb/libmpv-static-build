#!/bin/bash
set -euo pipefail

PKGNAME="libbluray"
PKGVER="1.3.4-4"
SOURCE_ARCHIVE_SHA256="c21ad4d540db94f675ed1edd86be5559be4a8af5438983de0225621200fc40de"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/ShiftMediaProject/libbluray/archive/refs/tags/${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Run bootstrap to generate configure script
    ./bootstrap

    generate_cross_env
    . cross.env

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-shared \
        --enable-static \
        --disable-doxygen-doc \
        --disable-examples \
        --disable-bdjava-jar \
        --with-freetype \
        --with-libxml2 \
        --with-libudfread

    make
    make install

    # Rename .lib to .a for compatibility with lld linker
    mv "${OUTPUT_BASE}/lib/libbluray.lib" "${OUTPUT_BASE}/lib/libbluray.a"
}

run "$@"
