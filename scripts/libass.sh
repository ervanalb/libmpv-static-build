#!/bin/bash
set -euo pipefail

PKGNAME="libass"
PKGVER="0.17.4"
SOURCE_ARCHIVE_SHA256="a886b3b80867f437bc55cff3280a652bfa0d37b43d2aff39ddf3c4f288b8c5a8"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/libass/libass/releases/download/${PKGVER}/${SOURCE_ARCHIVE}"
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
        -Dfontconfig=enabled \
        -Ddirectwrite=enabled \
        -Dlibunibreak=enabled \
        -Dtest=disabled \
        -Dcompare=disabled \
        -Dprofile=disabled \
        -Dfuzz=disabled \
        -Dcheckasm=disabled

    meson_ninja_remove_invalid_linker_args builddir
    ninja -C builddir
    ninja -C builddir install

    # Write corrected libass.pc file
    cat > "${OUTPUT_BASE}/lib/pkgconfig/libass.pc" <<EOF
prefix=${OUTPUT_BASE}
includedir=\${prefix}/include
libdir=\${prefix}/lib

Name: libass
Description: libass is an SSA/ASS subtitles rendering library
Version: ${PKGVER}
Requires: freetype2 >=  9.17.3, fribidi >=  0.19.1, harfbuzz >=  1.2.3, libunibreak >=  1.1, fontconfig >=  2.10.92
Libs: -L\${libdir} -lass -lgdi32
Cflags: -I\${includedir}
EOF
}

run "$@"
