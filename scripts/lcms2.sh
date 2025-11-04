#!/bin/bash
set -euo pipefail

PKGNAME="lcms2"
PKGVER="2.17"
SOURCE_ARCHIVE_SHA256="d11af569e42a1baa1650d20ad61d12e41af4fead4aa7964a01f93b08b53ab074"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/mm2/Little-CMS/releases/download/lcms${PKGVER}/${SOURCE_ARCHIVE}"
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
        -Dfastfloat=true \
        -Dthreaded=true \
        -Dtests=disabled


    meson_ninja_remove_invalid_linker_args builddir
    ninja -C builddir
    ninja -C builddir install
}

run "$@"
