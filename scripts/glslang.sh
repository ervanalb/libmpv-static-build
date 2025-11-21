#!/bin/bash
set -euo pipefail

PKGNAME="glslang"
PKGVER="16.0.0"
SOURCE_ARCHIVE_SHA256="172385478520335147d3b03a1587424af0935398184095f24beab128a254ecc7"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/KhronosGroup/glslang/archive/refs/tags/${PKGVER}.tar.gz"
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
        -DENABLE_OPT=OFF \
        -DENABLE_GLSLANG_BINARIES=OFF \
        -DCMAKE_C_FLAGS="-DMINGW_HAS_SECURE_API=0" \
        -DCMAKE_CXX_FLAGS="-DMINGW_HAS_SECURE_API=0"

    ninja
    ninja install
}

run "$@"
