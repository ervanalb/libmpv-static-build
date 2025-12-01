#!/bin/bash
set -euo pipefail

# These scripts generate dylibs in the output/ folder.
# This is intended to simulate shared objects that are expected to be present
# on a target linux system (and will not be statically linked into the final executable)

SCRIPTS_DIR="$(dirname "$0")"

ALL_SCRIPTS=(
    zlib.sh
    xorg-macros.sh
    xcb-proto.sh
    xorgproto.sh
    xtrans.sh
    libxau.sh
    libxcb.sh
    libx11.sh
    libxext.sh
    libxshmfence.sh
    libxrender.sh
    libxrandr.sh
    mesa.sh
    alsa.sh
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
