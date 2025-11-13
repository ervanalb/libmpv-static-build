#!/bin/bash
set -euo pipefail

PKGNAME="libopenmpt"
PKGVER="0.7.12+release.autotools"
SOURCE_ARCHIVE_SHA256="79ab3ce3672601e525b5cc944f026c80c03032f37d39caa84c8ca3fdd75e0c98"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://lib.openmpt.org/files/libopenmpt/src/${SOURCE_ARCHIVE}"
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
        --disable-openmpt123 \
        --disable-examples \
        --disable-tests \
        --disable-doxygen-doc \
        --disable-doxygen-html \
        --without-mpg123 \
        --without-flac

    make
    make install

    # Rename .lib to .a for compatibility with lld linker
    mv "${OUTPUT_BASE}/lib/libopenmpt.lib" "${OUTPUT_BASE}/lib/libopenmpt.a"
}

run "$@"
