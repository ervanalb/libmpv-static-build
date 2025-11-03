#!/bin/bash
set -euo pipefail

PKGNAME="expat"
PKGVER="2.7.3"
SOURCE_ARCHIVE_SHA256="821ac9710d2c073eaf13e1b1895a9c9aa66c1157a99635c639fbff65cdbdd732"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/libexpat/libexpat/releases/download/R_2_7_3/${SOURCE_ARCHIVE}"
}

build() {
    extract;
    setup_output;

    cd "$WORK"
    generate_cmake_toolchain_file;

    mkdir build
    cd build

    cmake .. \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE} \
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE} \
        -DBUILD_SHARED_LIBS=OFF \
        -DEXPAT_BUILD_DOCS=OFF \
        -DEXPAT_BUILD_EXAMPLES=OFF \
        -DEXPAT_BUILD_FUZZERS=OFF \
        -DEXPAT_BUILD_TESTS=OFF \
        -DEXPAT_BUILD_TOOLS=OFF \
        -DEXPAT_BUILD_PKGCONFIG=ON

    ninja
    ninja install
}

run "$@"
