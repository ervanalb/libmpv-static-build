#!/bin/bash
set -euo pipefail

PKGNAME="libpng"
PKGVER="1.6.50"
SOURCE_ARCHIVE_SHA256="71158e53cfdf2877bc99bcab33641d78df3f48e6e0daad030afe9cb8c031aa46"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/pnggroup/libpng/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"
    mkdir -p builddir
    cd builddir

    generate_cmake_toolchain_file

    cmake .. \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE} \
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE} \
        -DBUILD_SHARED_LIBS=OFF \
        -DPNG_SHARED=OFF \
        -DPNG_TESTS=OFF \
        -DPNG_TOOLS=OFF

    ninja
    ninja install
}

run "$@"
