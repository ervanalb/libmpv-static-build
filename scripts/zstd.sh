#!/bin/bash
set -euo pipefail

PKGNAME="zstd"
PKGVER="1.5.7"
SOURCE_ARCHIVE_SHA256="eb33e51f49a15e023950cd7825ca74a4a2b43db8354825ac24fc1b7ee09e6fa3"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/facebook/zstd/releases/download/v${PKGVER}/${SOURCE_ARCHIVE}"
}

build() {
    extract;
    setup_output;

    cd "$WORK/build/meson"

    generate_meson_cross;

    meson setup builddir \
        --prefix=${OUTPUT_BASE} \
        --libdir=${OUTPUT_BASE}/lib \
        --cross-file=meson_cross.txt \
        --buildtype=release \
        --default-library=static \
        -Dlegacy_level=0 \
        -Ddebug_level=0 \
        -Dbin_programs=false \
        -Dzlib=disabled \
        -Dlzma=disabled \
        -Dlz4=disabled

    meson_ninja_remove_invalid_linker_args builddir
    ninja -C builddir
    ninja -C builddir install
}

run "$@"
