#!/bin/bash
set -euo pipefail

PKGNAME="libarchive"
PKGVER="3.8.2"
SOURCE_ARCHIVE_SHA256="5f2d3c2fde8dc44583a61165549dc50ba8a37c5947c90fc02c8e5ce7f1cfb80d"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/libarchive/libarchive/releases/download/v${PKGVER}/${SOURCE_ARCHIVE}"
}

build() {
    extract;
    setup_output;

    cd "$WORK"
    generate_cmake_toolchain_file;

    mkdir builddir
    cd builddir

    CMAKE_OPTS=(
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE}
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE}
        -DCMAKE_INSTALL_LIBDIR=lib
        -DBUILD_SHARED_LIBS=OFF
        -DENABLE_ZLIB=ON
        -DENABLE_ZSTD=ON
        -DENABLE_OPENSSL=ON
        -DENABLE_BZip2=ON
        -DENABLE_ICONV=ON
        -DENABLE_LIBXML2=ON
        -DENABLE_EXPAT=ON
        -DENABLE_LZO=OFF
        -DENABLE_LZMA=ON
        -DENABLE_CPIO=OFF
        -DENABLE_CAT=OFF
        -DENABLE_TAR=OFF
        -DENABLE_WERROR=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_TEST=OFF
        -DENABLE_ACL=OFF
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    )

    case "$OS" in
        "LINUX")
            # For Linux static linking, manually add OpenSSL's compression dependencies
            # CMake's FindOpenSSL doesn't handle transitive deps from libcrypto.pc
            # Need to add both brotli AND zstd here because of link order issues
            CMAKE_OPTS+=("-DCMAKE_EXE_LINKER_FLAGS=-Wl,--start-group -lbrotlienc -lbrotlidec -lbrotlicommon -lzstd -lm -ldl -pthread -Wl,--end-group")
            ;;
        "WINDOWS")
            CMAKE_OPTS+=(
                -DWINDOWS_VERSION=WIN10
                -DHAVE_NL_LANGINFO=0
                -DHAVE_LANGINFO_H=0
                -DHAVE_SYMLINK=0
                -DHAVE_LCHMOD=0
                -DHAVE_FCHMOD=0
                -DHAVE_FORK=0
                -DHAVE_VFORK=0
                -DHAVE_PIPE=0
            )
            ;;
    esac

    cmake .. "${CMAKE_OPTS[@]}"
    ninja
    ninja install
}

run "$@"
