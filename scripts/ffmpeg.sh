#!/bin/bash
set -euo pipefail

PKGNAME="ffmpeg"
PKGVER="8.0"
SOURCE_ARCHIVE_SHA256="cce1136d38c389e6baaa452d6babc384cb2d3a9406ebe48c36a48f3ee115d8df"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://ffmpeg.org/releases/ffmpeg-${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    source cross.env

    ./configure \
        --prefix=${OUTPUT_BASE} \
        --arch=x86_64 \
        --target-os=mingw32 \
        --cc="$CC" \
        --cxx="$CXX" \
        --ld="$LD" \
        --ar="$AR" \
        --ranlib="$RANLIB" \
        --windres=x86_64-w64-mingw32-windres \
        --pkg-config-flags=--static \
        --enable-cross-compile \
        --enable-static \
        --disable-shared \
        --enable-runtime-cpudetect \
        --enable-version3 \
        --enable-vapoursynth \
        --enable-libass \
        --enable-libbluray \
        --enable-libfreetype \
        --enable-libfribidi \
        --enable-libfontconfig \
        --enable-libharfbuzz \
        --enable-libmodplug \
        --enable-libopenmpt \
        --enable-libmp3lame \
        --enable-lcms2 \
        --enable-libopus \
        --enable-libsoxr \
        --enable-libspeex \
        --enable-libvorbis \
        --enable-libbs2b \
        --enable-libvpx \
        --enable-libwebp \
        --enable-libaom \
        --enable-libsvtav1 \
        --enable-libdav1d \
        --enable-libuavs3d \
        --enable-libzimg \
        --enable-openssl \
        --enable-libxml2 \
        --enable-libmysofa \
        --enable-libvpl \
        --enable-libjxl \
        --enable-libplacebo \
        --enable-libshaderc \
        --enable-libaribcaption \
        --enable-amf \
        --enable-openal \
        --enable-opengl \
        --disable-doc \
        --disable-ffplay \
        --disable-ffprobe \
        --enable-vaapi \
        --disable-vdpau \
        --disable-videotoolbox \
        --extra-cflags='-Wno-error=int-conversion -DAL_LIBTYPE_STATIC' \
        --extra-ldflags='-static-libgcc -static-libstdc++ -Wl,--allow-multiple-definition' \
        --extra-libs='-lwinmm -lavrt -latomic -lole32 -lshell32 -luuid -lstdc++ -pthread'

    make
    make install
}

run "$@"
