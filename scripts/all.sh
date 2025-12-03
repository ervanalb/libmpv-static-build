#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="$(dirname "$0")"

ALL_SCRIPTS=(
    zstd.sh
    xz.sh
    brotli.sh
    bzip2.sh
    expat.sh
    openssl.sh
    libarchive.sh
    angle-headers.sh
    amf-headers.sh
    libiconv.sh
    lame.sh
    libjpeg.sh
    lcms2.sh
    libpng.sh
    libunibreak.sh
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
    libzimg.sh
    libmysofa.sh
    opus.sh
    ogg.sh
    speex.sh
    vorbis.sh
    libvpl.sh
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
    libaribcaption.sh
    aom.sh
    svtav1.sh
    dav1d.sh
    uavs3d.sh
    libpciaccess.sh
    libdrm.sh
    libva.sh
    openal-soft.sh
    vapoursynth.sh
    ffmpeg.sh
    lua.sh
    uchardet.sh
    mujs.sh
    mpv.sh
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
