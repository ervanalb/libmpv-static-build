#!/bin/bash
set -euo pipefail

PKGNAME="fontconfig"
PKGVER="2.15.0"
SOURCE_ARCHIVE_SHA256="f5f359d6332861bd497570848fcb42520964a9e83d5e3abe397b6b6db9bcaaf4"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://www.freedesktop.org/software/fontconfig/release/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Apply patches
    for patch in "${BASE}/patches/fontconfig-"*.patch; do
        patch -p1 < "$patch"
    done

    # Modify src/meson.build to use static library only
    sed -i "s/both_libraries/library/g" src/meson.build

    generate_meson_cross

    meson setup builddir \
        --prefix="${OUTPUT_BASE}" \
        --libdir="${OUTPUT_BASE}/lib" \
        --cross-file=meson_cross.txt \
        --buildtype=release \
        --default-library=static \
        -Ddoc=disabled \
        -Dtests=disabled \
        -Dtools=disabled \
        -Dcache-build=disabled

    meson_ninja_remove_invalid_linker_args builddir
    ninja -C builddir
    ninja -C builddir install
}

run "$@"
