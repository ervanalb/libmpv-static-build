#!/bin/bash
set -euo pipefail

PKGNAME="util-macros"
PKGVER="1.20.1"
SOURCE_ARCHIVE_SHA256="0b308f62dce78ac0f4d9de6888234bf170f276b64ac7c96e99779bb4319bcef5"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/util/util-macros-${PKGVER}.tar.xz"
}

build() {
    # Skip on Windows
    case "$OS" in
        "WINDOWS")
            echo "Skipping xorg-macros on Windows"
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
    mv "${OUTPUT_BASE}/share/pkgconfig/xorg-macros.pc" "${OUTPUT_BASE}/lib/pkgconfig/"
}

run "$@"
