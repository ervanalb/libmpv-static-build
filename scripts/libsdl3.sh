#!/bin/bash
set -euo pipefail

PKGNAME="SDL3"
PKGVER="3.2.26"
SOURCE_ARCHIVE_SHA256="dad488474a51a0b01d547cd2834893d6299328d2e30f479a3564088b5476bae2"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/libsdl-org/SDL/releases/download/release-${PKGVER}/${SOURCE_ARCHIVE}"
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
        -DSDL_VULKAN=ON \
        -DSDL_TEST_LIBRARY=OFF \
        -DSDL_JACK=OFF \
        -DSDL_PIPEWIRE=OFF \
        -DSDL_PULSEAUDIO=OFF

    ninja
    ninja install
}

run "$@"
