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
