#!/bin/bash
set -euo pipefail

PKGNAME="libudfread"
PKGVER="1.2.0"
SOURCE_ARCHIVE_SHA256="adcce1190925f9d35a477757c5e3f0e221315d14d3d45b4ae62540ea0925f877"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://code.videolan.org/videolan/libudfread/-/archive/${PKGVER}/${SOURCE_ARCHIVE}"
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
        --default-library=static

    meson_ninja_remove_invalid_linker_args builddir
    ninja -C builddir
    ninja -C builddir install
}

run "$@"
