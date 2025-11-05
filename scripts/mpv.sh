#!/bin/bash
set -euo pipefail

PKGNAME="mpv"
PKGVER="0.40.0"
SOURCE_ARCHIVE_SHA256="10a0f4654f62140a6dd4d380dcf0bbdbdcf6e697556863dc499c296182f081a3"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/mpv-player/mpv/archive/refs/tags/v${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Apply FFmpeg 8 compatibility patch
    patch -p1 < "$PATCH_BASE/mpv-0.40.0-ffmpeg8-compat.patch"

    # Patch meson.build to use iconv_ instead of iconv
    patch_meson_iconv_dependency

    generate_meson_cross

    # Configure mpv with LGPL-compatible options only
    meson setup build \
        --prefix=${OUTPUT_BASE} \
        --libdir=${OUTPUT_BASE}/lib \
        --cross-file=meson_cross.txt \
        --default-library=static \
        --prefer-static \
        -Dgpl=false \
        -Ddebug=true \
        -Db_ndebug=false \
        -Doptimization=3 \
        -Db_lto=true \
        -Dcplayer=false \
        -Dlibmpv=true \
        -Dpdf-build=disabled \
        -Dlua=enabled \
        -Djavascript=enabled \
        -Dlibarchive=enabled \
        -Dlibbluray=enabled \
        -Ddvdnav=disabled \
        -Duchardet=enabled \
        -Drubberband=disabled \
        -Dlcms2=enabled \
        -Dopenal=enabled \
        -Dspirv-cross=enabled \
        -Dvulkan=enabled \
        -Dvapoursynth=disabled \
        -Dgl=enabled \
        -Degl-angle=enabled \

    ninja -C build
    ninja -C build install

    # Also install mpv headers
    mkdir -p "${OUTPUT_BASE}/include/mpv"
    install -p -m 0644 include/mpv/client.h "${OUTPUT_BASE}/include/mpv/"
    install -p -m 0644 include/mpv/stream_cb.h "${OUTPUT_BASE}/include/mpv/"
    install -p -m 0644 include/mpv/render.h "${OUTPUT_BASE}/include/mpv/"
    install -p -m 0644 include/mpv/render_gl.h "${OUTPUT_BASE}/include/mpv/"

    # Create pkg-config file for libmpv
    cat > "${OUTPUT_BASE}/lib/pkgconfig/mpv.pc" <<EOF
prefix=${OUTPUT_BASE}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: mpv
Description: mpv media player client library
Version: ${PKGVER}
Requires:
Libs: -L\${libdir} -lmpv
Cflags: -I\${includedir}
EOF
}

run "$@"
