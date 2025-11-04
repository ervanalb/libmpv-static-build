#!/bin/bash
set -euo pipefail

PKGNAME="libogg"
PKGVER="1.3.6"
SOURCE_ARCHIVE_SHA256="83e6704730683d004d20e21b8f7f55dcb3383cdf84c0daedf30bde175f774638"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://downloads.xiph.org/releases/ogg/${SOURCE_ARCHIVE}"
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
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5

    ninja
    ninja install
}

run "$@"
