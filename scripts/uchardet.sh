#!/bin/bash
set -euo pipefail

PKGNAME="uchardet"
PKGVER="0.0.5"
SOURCE_ARCHIVE_SHA256="7c5569c8ee1a129959347f5340655897e6a8f81ec3344de0012a243f868eabd1"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/BYVoid/uchardet/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Update minimum CMake version (2.8 is too old for modern CMake)
    sed -i'' -e 's/cmake_minimum_required(VERSION 2.8)/cmake_minimum_required(VERSION 3.5)/' CMakeLists.txt

    # Remove the tools subdirectory build (we don't need the executable)
    sed -i'' -e 's/^add_subdirectory(tools)/#add_subdirectory(tools)/' src/CMakeLists.txt

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
        -DBUILD_STATIC=ON

    ninja
    ninja install

    # Remove dynamic libs if they were built
    rm -f "${OUTPUT_BASE}/lib/libuchardet.so"*
    rm -f "${OUTPUT_BASE}/lib/libuchardet.dll.a"
    rm -f "${OUTPUT_BASE}/bin/libuchardet.dll"
    rm -f "${OUTPUT_BASE}/lib/libuchardet."*dylib
}

run "$@"
