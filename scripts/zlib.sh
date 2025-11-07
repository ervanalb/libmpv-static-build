#!/bin/bash
set -euo pipefail

PKGNAME="zlib"
PKGVER="1.3.1"
SOURCE_ARCHIVE_SHA256="9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/madler/zlib/releases/download/v${PKGVER}/${SOURCE_ARCHIVE}"
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
        -DINSTALL_PKGCONFIG_DIR=${OUTPUT_BASE}/lib/pkgconfig \
        -DBUILD_SHARED_LIBS=OFF \
        -DZLIB_BUILD_EXAMPLES=OFF

    ninja
    ninja install
}

run "$@"
