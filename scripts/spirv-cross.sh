#!/bin/bash
set -euo pipefail

PKGNAME="SPIRV-Cross"
PKGVER="MoltenVK-1.1.5"
SOURCE_ARCHIVE_SHA256="e11845d9a4ccb4666923a8b678935cf78acad2b4fc131aba779f5bcc6def5191"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/KhronosGroup/SPIRV-Cross/archive/refs/tags/${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Apply the static linking patch
    patch -p1 < ${PATCH_BASE}/spirv-cross-0001-static-linking-hacks.patch

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
        -DSPIRV_CROSS_SHARED=ON \
        -DSPIRV_CROSS_CLI=OFF \
        -DSPIRV_CROSS_ENABLE_TESTS=OFF \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5

    ninja
    ninja install

    # Create symlink for pkg-config compatibility
    cd ${OUTPUT_BASE}/lib/pkgconfig
    if [ -f spirv-cross-c-shared.pc ]; then
        ln -sf spirv-cross-c-shared.pc spirv-cross.pc
    fi
}

run "$@"
