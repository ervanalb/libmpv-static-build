#!/bin/bash
set -euo pipefail

PKGNAME="shaderc"
PKGVER="2025.4"
SOURCE_ARCHIVE_SHA256="8a89fb6612ace8954470aae004623374a8fc8b7a34a4277bee5527173b064faf"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/google/shaderc/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Shaderc expects dependencies in third_party directory
    mkdir -p third_party

    # Symlink glslang, spirv-headers, and spirv-tools
    ln -sf /home/eric/libmpv-static-build/work/glslang-16.0.0 third_party/glslang
    ln -sf /home/eric/libmpv-static-build/work/SPIRV-Headers-vulkan-sdk-1.4.328.1 third_party/spirv-headers
    ln -sf /home/eric/libmpv-static-build/work/SPIRV-Tools-2025.4 third_party/spirv-tools

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
        -DSHADERC_SKIP_TESTS=ON \
        -DSHADERC_SKIP_SPVC=ON \
        -DSHADERC_SKIP_EXAMPLES=ON \
        -DSPIRV_SKIP_EXECUTABLES=ON \
        -DSPIRV_SKIP_TESTS=ON \
        -DENABLE_SPIRV_TOOLS_INSTALL=ON \
        -DENABLE_GLSLANG_BINARIES=OFF \
        -DSPIRV_TOOLS_BUILD_STATIC=ON \
        -DSPIRV_TOOLS_LIBRARY_TYPE=STATIC \
        -DCMAKE_CXX_FLAGS="-std=c++17"

    ninja

    # Manual install of libshaderc_combined
    cp libshaderc/libshaderc_combined.a ${OUTPUT_BASE}/lib/
    cp -r ../libshaderc/include/shaderc ${OUTPUT_BASE}/include/

    # Install pkg-config file if it exists
    if [ -f shaderc_combined.pc ]; then
        cp shaderc_combined.pc ${OUTPUT_BASE}/lib/pkgconfig/shaderc.pc
    fi
}

run "$@"
