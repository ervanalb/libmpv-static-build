#!/bin/bash
set -euo pipefail

PKGNAME="libmysofa"
PKGVER="1.3.2"
SOURCE_ARCHIVE_SHA256="6c5224562895977e87698a64cb7031361803d136057bba35ed4979b69ab4ba76"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/hoene/libmysofa/archive/refs/tags/v${PKGVER}.tar.gz"
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
        -DMATH=m \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5

    ninja
    ninja install
}

run "$@"
