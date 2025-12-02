#!/bin/bash
set -euo pipefail

PKGNAME="libX11"
PKGVER="1.8.10"
SOURCE_ARCHIVE_SHA256="2b3b3dad9347db41dca56beb7db5878f283bde1142f04d9f8e478af435dfdc53"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/lib/libX11-${PKGVER}.tar.xz"
}

build() {
    # Linux-only
    if [[ "$OS" != "LINUX" ]]; then
        echo "Skipping libX11 (Linux-only)"
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
        --enable-shared \
        --disable-specs \
        --without-xmlto \
        --without-fop \
        --without-xsltproc \
        --disable-malloc0returnsnull

    make
    make install
}

run "$@"
