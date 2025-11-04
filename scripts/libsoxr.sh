#!/bin/bash
set -euo pipefail

PKGNAME="soxr"
PKGVER="0.1.3"
SOURCE_ARCHIVE_SHA256="db6ca1b1e8405c6ef92f8294fc123d910abf0a114003b3f0f13fa57a95fd62d0"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/chirlu/soxr/archive/refs/tags/${PKGVER}.tar.gz"
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
        -DBUILD_TESTS=OFF \
        -DWITH_OPENMP=OFF \
        -DHAVE_WORDS_BIGENDIAN_EXITCODE=1 \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5

    ninja
    ninja install
}

run "$@"
