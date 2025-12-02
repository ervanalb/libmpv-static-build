#!/bin/bash
set -euo pipefail

PKGNAME="libvpl"
PKGVER="2.15.0"
SOURCE_ARCHIVE_SHA256="7218c3b8206b123204c3827ce0cf7c008d5c693c1f58ab461958d05fe6f847b3"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/intel/libvpl/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    # Intel VPL is not available on macOS
    if [[ "$OS" == "MACOS" ]]; then
        echo "Skipping libvpl (not available on macOS)"
        return 0
    fi

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
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_EXPERIMENTAL=OFF \
        -DINSTALL_DEV=ON \
        -DINSTALL_LIB=ON

    ninja
    ninja install
}

run "$@"
