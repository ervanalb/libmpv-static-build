#!/bin/bash
set -euo pipefail

PKGNAME="spirv-headers"
PKGVER="1.4.328.1"
SOURCE_ARCHIVE_SHA256="602364ab7bf404a7f352df7da5c645f1c4558a9c92616f8ee33422b04d5e35b7"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/KhronosGroup/SPIRV-Headers/archive/refs/tags/vulkan-sdk-${PKGVER}.tar.gz"
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
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE}

    ninja install
}

run "$@"
