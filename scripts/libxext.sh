#!/bin/bash
set -euo pipefail

PKGNAME="libXext"
PKGVER="1.3.6"
SOURCE_ARCHIVE_SHA256="edb59fa23994e405fdc5b400afdf5820ae6160b94f35e3dc3da4457a16e89753"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/lib/libXext-${PKGVER}.tar.xz"
}

build() {
    # Skip on Windows
    case "$OS" in
        "WINDOWS")
            echo "Skipping libXext on Windows"
            return 0
            ;;
    esac

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
        --disable-malloc0returnsnull

    make
    make install
}

run "$@"
