#!/bin/bash
set -euo pipefail

PKGNAME="lame"
PKGVER="3.100-6"
SOURCE_ARCHIVE_SHA256="adafd3c0af6f024373fe2566f0534f53024ba412c515da52a961fc83135b9b9e"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://gitlab.com/shinchiro/lame/-/archive/debian/${PKGVER}/${SOURCE_ARCHIVE}"
}

build() {
    extract;
    setup_output;

    cd "$WORK"

    # Apply debian patches
    if [ -f debian/patches/series ]; then
        for patch in $(cat debian/patches/series); do
            patch -N -p1 < debian/patches/$patch || true
        done
    fi

    # Set up environment for cross-compilation
    generate_cross_env
    . cross.env

    autoupdate -f

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-shared \
        --disable-frontend

    make -j$(nproc)
    make install
}

run "$@"
