#!/bin/bash
set -euo pipefail

PKGNAME="libxml2"
PKGVER="2.15.1"
SOURCE_ARCHIVE_SHA256="23b1ebd74cc562cd592cd2618c2bd88dc06fa0dfdbcd56e03cb26d6ff6b7e373"

source "$(dirname "$0")/common.sh"

# Override SOURCE_ARCHIVE to use the v prefix
SOURCE_ARCHIVE="v${PKGVER}.tar.gz"

download() {
    fetch_url "https://github.com/GNOME/libxml2/archive/refs/tags/${SOURCE_ARCHIVE}"
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
        -DLIBXML2_WITH_ZLIB=ON \
        -DLIBXML2_WITH_ICONV=ON \
        -DLIBXML2_WITH_PYTHON=OFF \
        -DLIBXML2_WITH_TESTS=OFF \
        -DLIBXML2_WITH_HTTP=OFF \
        -DLIBXML2_WITH_THREADS=ON \
        -DLIBXML2_WITH_THREAD_ALLOC=ON \
        -DLIBXML2_WITH_PROGRAMS=OFF \
        -DLIBXML2_WITH_MODULES=OFF

    ninja
    ninja install
}

run "$@"
