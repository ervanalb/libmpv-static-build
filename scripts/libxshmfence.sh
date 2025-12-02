#!/bin/bash
set -euo pipefail

PKGNAME="libxshmfence"
PKGVER="1.3.2"
SOURCE_ARCHIVE_SHA256="870df257bc40b126d91b5a8f1da6ca8a524555268c50b59c0acd1a27f361606f"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/lib/libxshmfence-${PKGVER}.tar.xz"
}

build() {
    # Linux-only
    if [[ "$OS" != "LINUX" ]]; then
        echo "Skipping libxshmfence (Linux-only)"
        return 0
    fi

    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    . cross.env

    # ./configure fails to pass LDFLAGS to linker which include -target
    export CC="$CC -target $TARGET_ARCH"

    ./configure \
        --host="${TARGET_ARCH}" \
        --prefix="${OUTPUT_BASE}" \
        --disable-static \
        --enable-shared

    make
    make install
}

run "$@"
