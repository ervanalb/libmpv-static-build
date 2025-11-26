#!/bin/bash
set -euo pipefail

PKGNAME="SVT-AV1"
PKGVER="3.1.2"
SOURCE_ARCHIVE_SHA256="d0d73bfea42fdcc1222272bf2b0e2319e9df5574721298090c3d28315586ecb1"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/v${PKGVER}/SVT-AV1-v${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    case "$TARGET_CPU_FAMILY" in
        "x86_64")
            CFLAGS="-mavx2"
            ;;
    esac
    generate_cmake_toolchain_file

    mkdir -p build
    cd build

    CMAKE_OPTS=(
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE}
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE}
        -DENABLE_AVX512=OFF
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_APPS=OFF
        -DSVT_AV1_LTO=OFF
    )

    cmake .. "${CMAKE_OPTS[@]}"

    ninja
    ninja install
}

run "$@"
