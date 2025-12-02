#!/bin/bash
set -euo pipefail

PKGNAME="angle-headers"
PKGVER="0"
GIT_COMMIT="3ef2a2c9c19f101d878fe41a6ad1ae20f6886f4a"

source "$(dirname "$0")/common.sh"

download() {
    GIT_CLONE_FLAGS=(--sparse --no-checkout --filter=tree:0)
    fetch_git "https://github.com/google/angle.git"
    cd "$FETCH"
    git sparse-checkout set --no-cone include/EGL include/KHR include/GLES2 include/GLES3
    git checkout -q "$GIT_COMMIT"
    create_tarball
}

build() {
    # Windows-only
    if [[ "$OS" != "WINDOWS" ]]; then
        echo "Skipping ANGLE headers (Windows-only)"
        return 0
    fi

    extract
    setup_output

    mkdir -p "$OUTPUT_BASE/include"
    cp -r "$WORK/include/EGL" "$OUTPUT_BASE/include/EGL"
    cp -r "$WORK/include/KHR" "$OUTPUT_BASE/include/KHR"
    cp -r "$WORK/include/GLES2" "$OUTPUT_BASE/include/GLES2"
    cp -r "$WORK/include/GLES3" "$OUTPUT_BASE/include/GLES3"
}

run "$@"
