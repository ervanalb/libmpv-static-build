#!/bin/bash
set -euo pipefail

PKGNAME="Vulkan-Headers"
PKGVER="1.4.331"
SOURCE_ARCHIVE_SHA256="7536a34b2b089fc85ce015060d2a114f3f298315104ee43f710e986d923d821b"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/KhronosGroup/Vulkan-Headers/archive/refs/tags/v${PKGVER}.tar.gz"
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
        -DVULKAN_HEADERS_ENABLE_MODULE=OFF

    # No build command - headers only
    ninja install
}

run "$@"
