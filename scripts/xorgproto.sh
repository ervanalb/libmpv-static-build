#!/bin/bash
set -euo pipefail

PKGNAME="xorgproto"
PKGVER="2024.1"
SOURCE_ARCHIVE_SHA256="372225fd40815b8423547f5d890c5debc72e88b91088fbfb13158c20495ccb59"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://xorg.freedesktop.org/archive/individual/proto/xorgproto-${PKGVER}.tar.xz"
}

build() {
    # Linux-only
    if [[ "$OS" != "LINUX" ]]; then
        echo "Skipping xorgproto (Linux-only)"
        return 0
    fi

    extract
    setup_output

    cd "$WORK"

    generate_meson_cross

    meson setup build \
        --prefix="${OUTPUT_BASE}" \
        --libdir="${OUTPUT_BASE}/lib" \
        --cross-file=meson_cross.txt \
        --buildtype=release

    meson_ninja_remove_invalid_linker_args build
    ninja -C build
    ninja -C build install

    # Move .pc files from share/pkgconfig to lib/pkgconfig for consistency
    mkdir -p "${OUTPUT_BASE}/lib/pkgconfig"
    mv "${OUTPUT_BASE}/share/pkgconfig/"*proto.pc "${OUTPUT_BASE}/lib/pkgconfig/"
}

run "$@"
