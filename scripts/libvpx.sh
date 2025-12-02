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

    generate_cross_env
    . cross.env

    case "$TARGET" in
        "x86_64-pc-windows-gnu")
            VPX_TARGET="x86_64-win64-gcc"
            ;;
        "x86_64-unknown-linux-gnu")
            VPX_TARGET="x86_64-linux-gcc"
            ;;
        "aarch64-unknown-linux-gnu")
            VPX_TARGET="arm64-linux-gcc"
            ;;
        "x86_64-apple-darwin")
            VPX_TARGET="x86_64-darwin20-gcc"
            ;;
        "aarch64-apple-darwin")
            VPX_TARGET="arm64-darwin20-gcc"
            ;;
    esac

    ./configure \
        --target=${VPX_TARGET} \
        --extra-cflags='-fno-asynchronous-unwind-tables' \
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
        --enable-vp9-highbitdepth \
        --disable-avx512

    make
    make install
}

run "$@"
