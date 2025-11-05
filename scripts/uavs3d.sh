#!/bin/bash
set -euo pipefail

PKGNAME="uavs3d"
PKGVER="1fd04917cff50fac72ae23e45f82ca6fd9130bd8"

source "$(dirname "$0")/common.sh"

download() {
    GIT_CLONE_FLAGS="--no-checkout"
    fetch_git "https://github.com/uavs3/uavs3d.git"

    cd "$FETCH"
    git checkout ${PKGVER}

    # Generate version.h using the provided script
    bash version.sh

    create_tarball
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
        -DCOMPILE_10BIT=ON \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5

    ninja
    ninja install
}

run "$@"
