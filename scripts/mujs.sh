#!/bin/bash
set -euo pipefail

PKGNAME="mujs"
PKGVER="1.3.7"
SOURCE_ARCHIVE_SHA256="fa15735edc4b3d27675d954b5703e36a158f19cfa4f265aa5388cd33aede1c70"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://mujs.com/downloads/mujs-${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    source cross.env

    # Build only the static library (no executables needed)
    make build/release/libmujs.a \
        CC="$CC" \
        AR="$AR" \
        CFLAGS="-std=c99 -Wall -Wextra -Wno-unused-parameter" \
        OPTIM="-O3"

    # Install manually
    mkdir -p "${OUTPUT_BASE}/include"
    mkdir -p "${OUTPUT_BASE}/lib"
    mkdir -p "${OUTPUT_BASE}/lib/pkgconfig"

    # Install header
    install -p -m 0644 mujs.h "${OUTPUT_BASE}/include/"

    # Install library
    install -p -m 0644 build/release/libmujs.a "${OUTPUT_BASE}/lib/"

    # Create pkg-config file
    cat > "${OUTPUT_BASE}/lib/pkgconfig/mujs.pc" <<EOF
prefix=${OUTPUT_BASE}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: mujs
Description: MuJS embeddable Javascript interpreter
Version: ${PKGVER}
Libs: -L\${libdir} -lmujs
Libs.private: -lm
Cflags: -I\${includedir}
EOF
}

run "$@"
