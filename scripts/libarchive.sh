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

    cmake .. \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${OUTPUT_BASE} \
        -DCMAKE_FIND_ROOT_PATH=${OUTPUT_BASE} \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_ZLIB=ON \
        -DENABLE_ZSTD=ON \
        -DENABLE_OPENSSL=ON \
        -DENABLE_BZip2=ON \
        -DENABLE_ICONV=ON \
        -DENABLE_LIBXML2=ON \
        -DENABLE_EXPAT=ON \
        -DENABLE_LZO=OFF \
        -DENABLE_LZMA=ON \
        -DENABLE_CPIO=OFF \
        -DENABLE_CAT=OFF \
        -DENABLE_TAR=OFF \
        -DENABLE_WERROR=OFF \
        -DBUILD_TESTING=OFF \
        -DENABLE_TEST=OFF \
        -DENABLE_ACL=OFF \
        -DWINDOWS_VERSION=WIN10 \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DHAVE_NL_LANGINFO=0 \
        -DHAVE_LANGINFO_H=0 \
        -DHAVE_SYMLINK=0 \
        -DHAVE_LCHMOD=0 \
        -DHAVE_FCHMOD=0 \
        -DHAVE_FORK=0 \
        -DHAVE_VFORK=0 \
        -DHAVE_PIPE=0 \
        -DCMAKE_C_FLAGS="-D__USE_MINGW_ANSI_STDIO=1 -D_UCRT" \
        -DCMAKE_CXX_FLAGS="-D__USE_MINGW_ANSI_STDIO=1 -D_UCRT"
    ninja
    ninja install
}

run "$@"
