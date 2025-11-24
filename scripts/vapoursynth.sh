#!/bin/bash
set -euo pipefail

PKGNAME="vapoursynth"
PKGVER="R71"
SOURCE_ARCHIVE_SHA256="c56d6de16d0a24db7eee1bd5e633229b0bd8a746eafcfe41945a22f9d44f8bd6"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/vapoursynth/vapoursynth/archive/refs/tags/${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    source cross.env

    ./autogen.sh

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-shared \
        --enable-static \
        --disable-python-module \
        --disable-vspipe \
        --disable-vsscript

    make
    make install

    # Rename .lib to .a (Windows only)
    if [[ "$OS" == "WINDOWS" ]]; then
        mv "${OUTPUT_BASE}/lib/libvapoursynth.lib" "${OUTPUT_BASE}/lib/libvapoursynth.a"
    fi
}

run "$@"
