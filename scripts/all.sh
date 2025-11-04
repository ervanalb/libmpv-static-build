#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="$(dirname "$0")"

ALL_SCRIPTS=(
    zstd.sh
    xz.sh
    zlib.sh
    brotli.sh
    bzip2.sh
    expat.sh
    openssl.sh
    libarchive.sh
    angle-headers.sh
    amf-headers.sh
    nvcodec_headers.sh
    libiconv.sh
    lame.sh
    libjpeg.sh
    lcms2.sh
    libpng.sh
    libunibreaki.sh
    freetype2.sh
    harfbuzz.sh
    fribidi.sh
    fontconfig.sh
    libass.sh
    libudfread.sh
    libxml2.sh
    libbluray.sh
    libsoxr.sh
    libmodplug.sh
    libbs2b.sh
    libvpx.sh
    libwebp.sh
    graphengine.sh
    libzimg.sh
    libmysofa.sh
    opus.sh
    ogg.sh
    speex.sh
    vorbis.sh
    libvpl.sh
    vulkan-headers.sh
    vulkan.sh
    libsdl3.sh
    libopenmpt.sh
    highway.sh
    libjxl.sh
    glslang.sh
    spirv-headers.sh
    spirv-tools.sh
    shaderc.sh
    spirv-cross.sh
    xxhash.sh
    libplacebo.sh

      #ffmpeg
        #libaribcaption
        #aom
        #svtav1
        #dav1d
        #vapoursynth
        #${ffmpeg_uavs3d}
        #libva
        #openal-soft
    #mpv.sh
)

download() {
    for SCRIPT in "${ALL_SCRIPTS[@]}"; do
        "$SCRIPTS_DIR/$SCRIPT" download
    done
}

build() {
    for SCRIPT in "${ALL_SCRIPTS[@]}"; do
        $SCRIPTS_DIR/$SCRIPT build
    done
}

ACTION="${1:-}"
case "$ACTION" in
    download)
        download
        ;;
    build)
        build
        ;;
    *)
        echo "Usage: $(basename $0) {download|build}" >&2
        exit 1
        ;;
esac
