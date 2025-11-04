#!/bin/bash
set -euo pipefail

PKGNAME="libjpeg"
PKGVER="libjpeg-turbo-3.0.3"
SOURCE_ARCHIVE_SHA256="dda8fd48da0f2007740bdb93495784542ea1f6160fddea285777991e3fefd5e4"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/winlibs/libjpeg/archive/refs/tags/${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"
    mkdir -p builddir
    cd builddir

    generate_cmake_toolchain_file

    cmake .. \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE} \
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE} \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_STATIC=ON \
        -DENABLE_SHARED=OFF \
        -DWITH_TURBOJPEG=OFF

    ninja
    ninja install
}

run "$@"
