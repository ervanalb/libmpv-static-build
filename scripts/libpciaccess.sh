#!/bin/bash
set -euo pipefail

PKGNAME="libpciaccess"
PKGVER="0.18.1"
SOURCE_ARCHIVE_SHA256="4af43444b38adb5545d0ed1c2ce46d9608cc47b31c2387fc5181656765a6fa76"

source "$(dirname "$0")/common.sh"

SOURCE_ARCHIVE="$PKGNAME-$PKGVER.tar.xz"

download() {
    fetch_url "https://xorg.freedesktop.org/releases/individual/lib/libpciaccess-${PKGVER}.tar.xz"
}

build() {
    # Skip libpciaccess on Windows - only needed for Linux
    case "$OS" in
        "WINDOWS")
            echo "Skipping libpciaccess on Windows (Linux only)"
            return 0
            ;;
        "LINUX")
            ;;
    esac

    extract
    setup_output

    cd "$WORK"

    generate_meson_cross

    meson setup build \
        --prefix=${OUTPUT_BASE} \
        --libdir=${OUTPUT_BASE}/lib \
        --cross-file=meson_cross.txt \
        --buildtype=release \
        --default-library=static

    meson_ninja_remove_invalid_linker_args build
    ninja -C build
    ninja -C build install
}

run "$@"
