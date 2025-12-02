#!/bin/bash
set -euo pipefail

PKGNAME="libdrm"
PKGVER="2.4.124"
SOURCE_ARCHIVE_SHA256="ac36293f61ca4aafaf4b16a2a7afff312aa4f5c37c9fbd797de9e3c0863ca379"

source "$(dirname "$0")/common.sh"

SOURCE_ARCHIVE="$PKGNAME-$PKGVER.tar.xz"

download() {
    fetch_url "https://dri.freedesktop.org/libdrm/libdrm-${PKGVER}.tar.xz"
}

build() {
    # Linux-only
    if [[ "$OS" != "LINUX" ]]; then
        echo "Skipping libdrm (Linux-only)"
        return 0
    fi

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
        -Dudev=false \
        -Dvalgrind=disabled \
        -Dcairo-tests=disabled \
        -Dtests=false \
        -Dintel=enabled \
        -Dradeon=enabled \
        -Damdgpu=enabled \
        -Dnouveau=enabled \
        -Dvmwgfx=disabled \
        -Domap=disabled \
        -Dexynos=disabled \
        -Dfreedreno=disabled \
        -Dtegra=disabled \
        -Dvc4=disabled \
        -Detnaviv=disabled \
        -Dman-pages=disabled

    meson_ninja_remove_invalid_linker_args build
    ninja -C build
    ninja -C build install
}

run "$@"
