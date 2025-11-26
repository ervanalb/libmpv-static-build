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

    # Apply the cross-compile and static linking patch (Windows only)
    if [[ "$OS" == "WINDOWS" ]]; then
        patch -p1 < ${PATCH_BASE}/vulkan-0001-cross-compile-static-linking-hacks.patch
    fi

    CFLAGS="-D__STDC_FORMAT_MACROS -DSTRSAFE_NO_DEPRECATE -Dparse_number=cjson_parse_number"
    CXXFLAGS="-D__STDC_FORMAT_MACROS -fpermissive"
    generate_cmake_toolchain_file

    mkdir -p build
    cd build

    # Disable WSI (Window System Integration) for Linux as we don't have X11/Wayland dependencies
    case "$OS" in
        "LINUX")
            WSI_OPTIONS="-DBUILD_WSI_XCB_SUPPORT=OFF -DBUILD_WSI_XLIB_SUPPORT=OFF -DBUILD_WSI_WAYLAND_SUPPORT=OFF"
            ;;
        "WINDOWS")
            WSI_OPTIONS=""
            ;;
    esac

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
        ${WSI_OPTIONS}

    ninja

    # Custom install commands as per cmake config
    case "$OS" in
        "WINDOWS")
            cp loader/libvulkan.a ${OUTPUT_BASE}/lib/libvulkan.a
            cp loader/vulkan_own.pc ${OUTPUT_BASE}/lib/pkgconfig/vulkan.pc
            ;;
        "LINUX")
            # On Linux, static loader doesn't build, use shared library
            ninja install
            ;;
    esac
}

run "$@"
