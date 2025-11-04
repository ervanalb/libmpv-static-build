#!/bin/bash
set -euo pipefail

PKGNAME="libvpx"
PKGVER="1.15.2"
SOURCE_ARCHIVE_SHA256="26fcd3db88045dee380e581862a6ef106f49b74b6396ee95c2993a260b4636aa"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/webmproject/libvpx/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    CROSS=${TARGET_ARCH}- ./configure \
        --extra-cflags='-fno-asynchronous-unwind-tables' \
        --target=x86_64-win64-gcc \
        --prefix=${OUTPUT_BASE} \
        --disable-examples \
        --disable-docs \
        --disable-tools \
        --disable-unit-tests \
        --disable-decode-perf-tests \
        --disable-encode-perf-tests \
        --disable-shared \
        --enable-static \
        --as=yasm \
        --enable-vp9-highbitdepth

    make
    make install
}

run "$@"
