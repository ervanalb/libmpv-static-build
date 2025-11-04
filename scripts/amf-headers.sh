#!/bin/bash
set -euo pipefail

PKGNAME="amf-headers"
PKGVER="v1.5.0"
SOURCE_ARCHIVE_SHA256="d569647fa26f289affe81a206259fa92f819d06db1e80cc334559953e82a3f01"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/GPUOpen-LibrariesAndSDKs/AMF/releases/download/v1.5.0/AMF-headers-${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    mkdir -p "$OUTPUT_BASE/include/AMF"
    cp -r "$WORK/AMF/components" "$OUTPUT_BASE/include/AMF/components"
    cp -r "$WORK/AMF/core" "$OUTPUT_BASE/include/AMF/core"
}

run "$@"
