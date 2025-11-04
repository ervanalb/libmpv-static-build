#!/bin/bash
set -euo pipefail

PKGNAME="harfbuzz"
PKGVER="12.1.0"
SOURCE_ARCHIVE_SHA256="e5c81b7f6e0b102dfb000cfa424538b8e896ab78a2f4b8a5ec8cae62ab43369e"

source "$(dirname "$0")/common.sh"

# Override SOURCE_ARCHIVE for .tar.xz
SOURCE_ARCHIVE="$PKGNAME-$PKGVER.tar.xz"

download() {
    fetch_url "https://github.com/harfbuzz/harfbuzz/releases/download/${PKGVER}/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_meson_cross

    meson setup builddir \
        --prefix="${OUTPUT_BASE}" \
        --libdir="${OUTPUT_BASE}/lib" \
        --cross-file=meson_cross.txt \
        --buildtype=release \
        --default-library=static \
        -Dicu=disabled \
        -Dglib=disabled \
        -Dgobject=disabled \
        -Dtests=disabled \
        -Ddocs=disabled \
        -Dbenchmark=disabled

    meson_ninja_remove_invalid_linker_args builddir
    ninja -C builddir
    ninja -C builddir install
}

run "$@"
