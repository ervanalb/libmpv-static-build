#!/bin/bash
set -euo pipefail

PKGNAME="fribidi"
PKGVER="1.0.16"
SOURCE_ARCHIVE_SHA256="1b1cde5b235d40479e91be2f0e88a309e3214c8ab470ec8a2744d82a5a9ea05c"

source "$(dirname "$0")/common.sh"

SOURCE_ARCHIVE="$PKGNAME-$PKGVER.tar.xz"

download() {
    fetch_url "https://github.com/fribidi/fribidi/releases/download/v${PKGVER}/${SOURCE_ARCHIVE}"
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
        -Dcpp_args='-DFRIBIDI_LIB_STATIC' \
        -Ddocs=false \
        -Dbin=false \
        -Dtests=false

    meson_ninja_remove_invalid_linker_args builddir
    ninja -C builddir
    ninja -C builddir install
}

run "$@"
