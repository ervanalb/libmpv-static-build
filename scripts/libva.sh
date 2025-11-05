#!/bin/bash
set -euo pipefail

PKGNAME="libva"
PKGVER="2.22.0"
SOURCE_ARCHIVE_SHA256="467c418c2640a178c6baad5be2e00d569842123763b80507721ab87eb7af8735"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/intel/libva/archive/refs/tags/${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Patch to build as static library
    sed -i "s/shared_library/library/g" va/meson.build

    generate_meson_cross

    meson setup build \
        --prefix=${OUTPUT_BASE} \
        --libdir=${OUTPUT_BASE}/lib \
        --cross-file=meson_cross.txt \
        --buildtype=release \
        --default-library=static \
        -Denable_docs=false \
        -Dwith_wayland=no \

    meson_ninja_remove_invalid_linker_args build
    ninja -C build
    ninja -C build install
}

run "$@"
