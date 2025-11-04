#!/bin/bash
set -euo pipefail

PKGNAME="xxHash"
PKGVER="0.8.3"
SOURCE_ARCHIVE_SHA256="aae608dfe8213dfd05d909a57718ef82f30722c392344583d3f39050c7f29a80"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/Cyan4973/xxHash/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_cmake_toolchain_file

    mkdir -p build
    cd build

    cmake ../cmake_unofficial \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=../toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE} \
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE} \
        -DBUILD_SHARED_LIBS=OFF \
        -DXXHASH_BUILD_XXHSUM=OFF

    ninja
    ninja install
}

run "$@"
