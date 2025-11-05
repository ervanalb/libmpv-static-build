#!/bin/bash
set -euo pipefail

PKGNAME="dav1d"
PKGVER="1.5.2"
SOURCE_ARCHIVE_SHA256="2fc0810b4cdf72784b3c107827ff10b1d83ec709a1ec1fbdbc6a932daf65ead6"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://code.videolan.org/videolan/dav1d/-/archive/${PKGVER}/dav1d-${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_meson_cross

    meson setup build \
        --prefix=${OUTPUT_BASE} \
        --libdir=${OUTPUT_BASE}/lib \
        --cross-file=meson_cross.txt \
        --buildtype=release \
        --default-library=static \
        -Denable_tools=false \
        -Denable_tests=false

    meson_ninja_remove_invalid_linker_args build
    ninja -C build
    ninja -C build install
}

run "$@"
