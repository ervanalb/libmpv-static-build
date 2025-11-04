#!/bin/bash
set -euo pipefail

PKGNAME="Vulkan-Loader"
PKGVER="1.4.331"
SOURCE_ARCHIVE_SHA256="c5ef1bf3c9c832c804339737bcd5a5433d6cd9095a9aa928e929d087f31c0198"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Apply the cross-compile and static linking patch
    patch -p1 < ${PATCH_BASE}/vulkan-0001-cross-compile-static-linking-hacks.patch

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
        -DVULKAN_HEADERS_INSTALL_DIR=${OUTPUT_BASE} \
        -DBUILD_TESTS=OFF \
        -DENABLE_WERROR=OFF \
        -DBUILD_STATIC_LOADER=ON \
        -DCMAKE_C_FLAGS="-D__STDC_FORMAT_MACROS -DSTRSAFE_NO_DEPRECATE -Dparse_number=cjson_parse_number" \
        -DCMAKE_CXX_FLAGS="-D__STDC_FORMAT_MACROS -fpermissive"

    ninja

    # Custom install commands as per cmake config
    cp loader/libvulkan.a ${OUTPUT_BASE}/lib/libvulkan.a
    cp loader/vulkan_own.pc ${OUTPUT_BASE}/lib/pkgconfig/vulkan.pc
}

run "$@"
