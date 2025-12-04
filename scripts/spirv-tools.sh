#!/bin/bash
set -euo pipefail

PKGNAME="spirv-tools"
PKGVER="2025.4"
SOURCE_ARCHIVE_SHA256="d256aa82de849bdce4b05060081dadcc9145c2173a056e8531f649f8975e582e"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/KhronosGroup/SPIRV-Tools/archive/refs/tags/v${PKGVER}.tar.gz"
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
        -DSPIRV_SKIP_TESTS=ON \
        -DSPIRV_SKIP_EXECUTABLES=ON \
        -DSPIRV_WERROR=OFF \
        -DSPIRV-Headers_SOURCE_DIR=${OUTPUT_BASE}

    # Build only the static libraries, not executables
    ninja SPIRV-Tools-static SPIRV-Tools-opt SPIRV-Tools-link SPIRV-Tools-reduce SPIRV-Tools-lint SPIRV-Tools-diff
    # Install libraries only
    ninja install

    # Remove dynamic libs if they were built
    rm -f "${OUTPUT_BASE}/bin/libSPIRV-Tools-shared.so"*
    rm -f "${OUTPUT_BASE}/lib/libSPIRV-Tools-shared.dll.a"
    rm -f "${OUTPUT_BASE}/bin/libSPIRV-Tools-shared.dll"
    rm -f "${OUTPUT_BASE}/bin/libSPIRV-Tools-shared."*dylib
}

run "$@"
