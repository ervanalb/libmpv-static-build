#!/bin/bash
set -euo pipefail

PKGNAME="libaribcaption"
PKGVER="1.1.1"
SOURCE_ARCHIVE_SHA256="278d03a0a662d00a46178afc64f32535ede2d78c603842b6fd1c55fa9cd44683"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/xqq/libaribcaption/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_cmake_toolchain_file

    mkdir -p build
    cd build

    cmake .. \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE} \
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE} \
        -DBUILD_SHARED_LIBS=OFF \
        -DARIBCC_BUILD_TESTS=OFF \
        -DARIBCC_SHARED_LIBRARY=OFF \
        -DARIBCC_USE_EMBEDDED_FREETYPE=OFF \
        -DARIBCC_NO_RTTI=ON \
        -DARIBCC_USE_FONTCONFIG=ON \
        -DARIBCC_USE_FREETYPE=ON \
        -DCMAKE_C_FLAGS="-DHAVE_OPENSSL=1" \
        -DCMAKE_CXX_FLAGS="-DHAVE_OPENSSL=1"

    ninja
    ninja install
}

run "$@"
