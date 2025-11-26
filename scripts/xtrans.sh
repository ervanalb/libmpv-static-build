#!/bin/bash
set -euo pipefail

PKGNAME="xtrans"
PKGVER="1.5.2"
SOURCE_ARCHIVE_SHA256="5c5cbfe34764a9131d048f03c31c19e57fb4c682d67713eab6a65541b4dff86c"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/lib/xtrans-${PKGVER}.tar.xz"
}

build() {
    # Skip on Windows
    case "$OS" in
        "WINDOWS")
            echo "Skipping xtrans on Windows"
            return 0
            ;;
    esac

    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    . cross.env

    ./configure \
        --host="${TARGET_ARCH}" \
        --prefix="${OUTPUT_BASE}"

    make
    make install

    # Move .pc file from share/pkgconfig to lib/pkgconfig for consistency
    mkdir -p "${OUTPUT_BASE}/lib/pkgconfig"
    mv "${OUTPUT_BASE}/share/pkgconfig/xtrans.pc" "${OUTPUT_BASE}/lib/pkgconfig/"
}

run "$@"
