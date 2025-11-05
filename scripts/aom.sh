#!/bin/bash
set -euo pipefail

PKGNAME="libaom"
PKGVER="3.13.1"
SOURCE_ARCHIVE_SHA256="19e45a5a7192d690565229983dad900e76b513a02306c12053fb9a262cbeca7d"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://storage.googleapis.com/aom-releases/libaom-${PKGVER}.tar.gz"
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
        -DENABLE_EXAMPLES=OFF \
        -DENABLE_DOCS=OFF \
        -DENABLE_TOOLS=OFF \
        -DENABLE_NASM=OFF \
        -DENABLE_TESTS=OFF \
        -DENABLE_TESTDATA=OFF \
        -DCONFIG_UNIT_TESTS=0 \
        -DCONFIG_AV1_DECODER=1 \
        -DENABLE_SVE=OFF \
        -DENABLE_SVE2=OFF

    ninja
    ninja install
}

run "$@"
