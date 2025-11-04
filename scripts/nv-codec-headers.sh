#!/bin/bash
set -euo pipefail

PKGNAME="nv-codec-headers"
PKGVER="13.0.19.0"
SOURCE_ARCHIVE_SHA256="13da39edb3a40ed9713ae390ca89faa2f1202c9dda869ef306a8d4383e242bee"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/FFmpeg/nv-codec-headers/releases/download/n${PKGVER}/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"
    make PREFIX="${OUTPUT_BASE}" install
}

run "$@"
