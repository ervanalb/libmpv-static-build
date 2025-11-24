#!/bin/bash
set -euo pipefail

PKGNAME="xz"
PKGVER="5.8.1"
SOURCE_ARCHIVE_SHA256="507825b599356c10dca1cd720c9d0d0c9d5400b9de300af00e4d1ea150795543"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/tukaani-project/xz/releases/download/v${PKGVER}/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"
    generate_cmake_toolchain_file

    mkdir build
    cd build

    cmake .. \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE} \
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE} \
        -DBUILD_SHARED_LIBS=OFF \
        -DXZ_TOOL_XZ=OFF \
        -DXZ_TOOL_XZDEC=OFF \
        -DXZ_TOOL_LZMADEC=OFF \
        -DXZ_TOOL_LZMAINFO=OFF \
        -DXZ_DOXYGEN=OFF

    ninja
    ninja install
}

run "$@"
