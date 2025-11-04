#!/bin/bash
set -euo pipefail

PKGNAME="libunibreak"
PKGVER="6.1"
SOURCE_ARCHIVE_SHA256="cc4de0099cf7ff05005ceabff4afed4c582a736abc38033e70fdac86335ce93f"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/adah1972/libunibreak/releases/download/libunibreak_6_1/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Set up environment for cross-compilation
    generate_cross_env
    . cross.env

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-shared

    make
    make install
}

run "$@"
