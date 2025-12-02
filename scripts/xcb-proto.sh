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
    # Linux-only
    if [[ "$OS" != "LINUX" ]]; then
        echo "Skipping xcb-proto (Linux-only)"
        return 0
    fi

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
