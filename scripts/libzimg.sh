#!/bin/bash
set -euo pipefail

PKGNAME="zimg"
PKGVER="3.0.6"
ZIMG_SHA256="be89390f13a5c9b2388ce0f44a5e89364a20c1c57ce46d382b1fcc3967057577"
ZIMG_URL="https://github.com/sekrit-twc/zimg/archive/refs/tags/release-${PKGVER}.tar.gz"
GRAPHENGINE_COMMIT="f06d7cb4d589ea4657f01b13613efb7437c8ecda"
GRAPHENGINE_URL="https://github.com/sekrit-twc/graphengine/archive/${GRAPHENGINE_COMMIT}.tar.gz"

source "$(dirname "$0")/common.sh"

download() {
    mkdir -p "$FETCH"
    mkdir -p "$DOWNLOADS_BASE"

    # Download zimg to FETCH folder
    wget -q "$ZIMG_URL" -O "$FETCH/zimg-${PKGVER}.tar.gz"

    # Verify zimg checksum
    echo "$ZIMG_SHA256 $FETCH/zimg-${PKGVER}.tar.gz" | sha256sum --check --status \
        || { echo "Error: checksum failed for zimg-${PKGVER}.tar.gz" >&2; exit 1; }

    # Download graphengine to FETCH folder
    wget -q "$GRAPHENGINE_URL" -O "$FETCH/graphengine-${GRAPHENGINE_COMMIT}.tar.gz"

    # Extract zimg to FETCH
    mkdir -p "$FETCH/zimg-temp"
    tar -xf "$FETCH/zimg-${PKGVER}.tar.gz" --strip-components=1 -C "$FETCH/zimg-temp"

    # Extract graphengine into FETCH/zimg-temp/graphengine
    mkdir -p "$FETCH/zimg-temp/graphengine"
    tar -xf "$FETCH/graphengine-${GRAPHENGINE_COMMIT}.tar.gz" --strip-components=1 -C "$FETCH/zimg-temp/graphengine"

    # Create combined tarball in downloads folder
    cd "$FETCH/zimg-temp"
    tar -zcf "$DOWNLOADS_BASE/$SOURCE_ARCHIVE" --transform="s,^,$PKGNAME-$PKGVER/," .
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Run autogen.sh to generate configure script
    ./autogen.sh

    generate_cross_env
    . cross.env

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-shared \
        --enable-static

    make
    make install

    # Localize conflicting math wrapper symbols to avoid duplicate symbol errors with mingw (Windows only)
    # These wrapper functions conflict with mingw's libmingwex.a implementations
    if [[ "$OS" == "WINDOWS" ]]; then
        x86_64-w64-mingw32-objcopy --localize-symbol=expf --localize-symbol=powf "${OUTPUT_BASE}/lib/libzimg.a"
    fi
}

run "$@"
