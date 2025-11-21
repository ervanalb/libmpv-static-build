#!/bin/bash
set -euo pipefail

PKGNAME="freetype"
PKGVER="2.14.1"
SOURCE_ARCHIVE_SHA256="174d9e53402e1bf9ec7277e22ec199ba3e55a6be2c0740cb18c0ee9850fc8c34"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://mirrors.dotsrc.org/gnu/freetype/freetype-${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_meson_cross

    meson setup builddir \
        --prefix="${OUTPUT_BASE}" \
        --libdir="${OUTPUT_BASE}/lib" \
        --cross-file=meson_cross.txt \
        --buildtype=release \
        --default-library=static \
        -Dharfbuzz=disabled \
        -Dtests=disabled \
        -Dbrotli=enabled \
        -Dzlib=enabled \
        -Dpng=enabled

    meson_ninja_remove_invalid_linker_args builddir
    ninja -C builddir
    ninja -C builddir install
}

run "$@"
