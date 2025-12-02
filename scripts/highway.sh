#!/bin/bash
set -euo pipefail

PKGNAME="highway"
PKGVER="1.3.0"
SOURCE_ARCHIVE_SHA256="e8d696900b45f4123be8a9d6866f4e7b6831bf599f4b9c178964d968e6a58a69"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/google/highway/releases/download/${PKGVER}/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_cmake_toolchain_file

    mkdir -p builddir
    cd builddir

    cmake .. \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE} \
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE} \
        -DBUILD_SHARED_LIBS=OFF \
        -DHWY_ENABLE_CONTRIB=OFF \
        -DHWY_ENABLE_EXAMPLES=OFF \
        -DHWY_ENABLE_TESTS=OFF

    ninja
    ninja install
}

run "$@"
