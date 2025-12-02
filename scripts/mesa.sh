#!/bin/bash
set -euo pipefail

PKGNAME="mesa"
PKGVER="24.3.2"
SOURCE_ARCHIVE_SHA256="ad9f5f3a6d2169e4786254ee6eb5062f746d11b826739291205d360f1f3ff716"
SOURCE_ARCHIVE="$PKGNAME-$PKGVER.tar.xz"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://archive.mesa3d.org/mesa-${PKGVER}.tar.xz"
}

build() {
    # Linux-only
    if [[ "$OS" != "LINUX" ]]; then
        echo "Skipping mesa (Linux-only)"
        return 0
    fi

    extract
    setup_output

    cd "$WORK"

    # Statically link zlib into the shared library
    LDFLAGS="-L${OUTPUT_BASE}/lib -Wl,-Bstatic -lz -Wl,-Bdynamic"

    generate_meson_cross

    meson setup build \
        --prefix="${OUTPUT_BASE}" \
        --libdir="${OUTPUT_BASE}/lib" \
        --cross-file=meson_cross.txt \
        --buildtype=release \
        --default-library=shared \
        -Dplatforms=x11 \
        -Dgallium-drivers=softpipe \
        -Dvulkan-drivers= \
        -Dglx=xlib \
        -Degl=disabled \
        -Dgles1=disabled \
        -Dgles2=disabled \
        -Dosmesa=false \
        -Dshared-glapi=enabled \
        -Dgbm=disabled \
        -Dllvm=disabled \
        -Dlmsensors=disabled

    meson_ninja_remove_invalid_linker_args build
    ninja -C build
    ninja -C build install
}

run "$@"
