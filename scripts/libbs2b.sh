#!/bin/bash
set -euo pipefail

PKGNAME="libbs2b"
PKGVER="3.1.0"
SOURCE_ARCHIVE_SHA256="6aaafd81aae3898ee40148dd1349aab348db9bfae9767d0e66e0b07ddd4b2528"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://sourceforge.net/projects/bs2b/files/libbs2b/${PKGVER}/${SOURCE_ARCHIVE}/download"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Apply patches
    patch -p1 < ${PATCH_BASE}/libbs2b-0001-build-library-only.patch
    patch -p1 < ${PATCH_BASE}/libbs2b-0002-remove-dist-lzma.patch

    # Regenerate configure script after patching configure.ac
    autoreconf -fi

    generate_cross_env
    . cross.env

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-shared \
        --enable-static

    make
    make install

    # Rename .lib to .a for compatibility with lld linker
    mv "${OUTPUT_BASE}/lib/libbs2b.lib" "${OUTPUT_BASE}/lib/libbs2b.a"
}

run "$@"
