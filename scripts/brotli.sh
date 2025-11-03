#!/bin/bash
set -euo pipefail

PKGNAME="brotli"
PKGVER="1.2.0"
SOURCE_ARCHIVE_SHA256="816c96e8e8f193b40151dad7e8ff37b1221d019dbcb9c35cd3fadbfe6477dfec"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/google/brotli/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    extract;
    setup_output;

    cd "$WORK"
    generate_cmake_toolchain_file;

    mkdir builddir
    cd builddir

    cmake .. \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE} \
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE} \
        -DBUILD_SHARED_LIBS=OFF \
        -DBROTLI_EMSCRIPTEN=OFF \
        -DBROTLI_BUILD_TOOLS=OFF

    ninja
    ninja install
}

run "$@"
