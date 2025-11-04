#!/bin/bash
set -euo pipefail

PKGNAME="opus"
PKGVER="1.5.2"
SOURCE_ARCHIVE_SHA256="65c1d2f78b9f2fb20082c38cbe47c951ad5839345876e46941612ee87f9a7ce1"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/xiph/opus/releases/download/v${PKGVER}/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_meson_cross

    meson setup build \
        --prefix=${OUTPUT_BASE} \
        --libdir=${OUTPUT_BASE}/lib \
        --cross-file=meson_cross.txt \
        --buildtype=release \
        --default-library=static \
        -Dhardening=false \
        -Dextra-programs=disabled \
        -Dtests=disabled \
        -Ddocs=disabled

    ninja -C build
    ninja -C build install
}

run "$@"
