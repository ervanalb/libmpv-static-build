#!/bin/bash
set -euo pipefail

PKGNAME="xcb-proto"
PKGVER="1.17.0"
SOURCE_ARCHIVE_SHA256="2c1bacd2110f4799f74de6ebb714b94cf6f80fb112316b1219480fd22562148c"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-${PKGVER}.tar.xz"
}

build() {
    # Skip on Windows
    case "$OS" in
        "WINDOWS")
            echo "Skipping xcb-proto on Windows"
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
}

run "$@"
