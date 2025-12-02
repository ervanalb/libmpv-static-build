#!/bin/bash
set -euo pipefail

PKGNAME="openal-soft"
PKGVER="1.24.3"
SOURCE_ARCHIVE_SHA256="7e1fecdeb45e7f78722b776c5cf30bd33934b961d7fd2a11e0494e064cc631ce"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/kcat/openal-soft/archive/refs/tags/${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    case "$OS" in
        "LINUX")
            CFLAGS=""
            CXXFLAGS=""
            ;;
        "WINDOWS")
            CFLAGS="-femulated-tls"
            CXXFLAGS="-femulated-tls"
            ;;
        "MACOS")
            CFLAGS=""
            CXXFLAGS=""
            ;;
    esac
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
        -DLIBTYPE=STATIC \
        -DALSOFT_UTILS=OFF \
        -DALSOFT_EXAMPLES=OFF \
        -DALSOFT_TESTS=OFF \
        -DALSOFT_BACKEND_PIPEWIRE=OFF \
        -DALSOFT_RTKIT=OFF \
        -DALSOFT_DLOPEN=OFF

    ninja
    ninja install
}

run "$@"
