#!/bin/bash
set -euo pipefail

PKGNAME="speex"
PKGVER="1.2.1"
SOURCE_ARCHIVE_SHA256="4b44d4f2b38a370a2d98a78329fefc56a0cf93d1c1be70029217baae6628feea"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "http://downloads.xiph.org/releases/speex/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    . cross.env

    # Set cache variables for cross-compilation type sizes
    export ac_cv_sizeof_short=2
    export ac_cv_sizeof_int=4
    export ac_cv_sizeof_long=8
    export ac_cv_sizeof_int16_t=2
    export ac_cv_sizeof_uint16_t=2
    export ac_cv_sizeof_u_int16_t=2
    export ac_cv_sizeof_int32_t=4
    export ac_cv_sizeof_uint32_t=4
    export ac_cv_sizeof_u_int32_t=4

    CONFIGURE_OPTS=(
        --host=${TARGET_ARCH}
        --prefix=${OUTPUT_BASE}
        --disable-shared
        --enable-static
        --disable-binaries
    )

    # SSE is x86-specific
    case "$TARGET_CPU_FAMILY" in
        "x86_64")
            CONFIGURE_OPTS+=(--enable-sse)
            ;;
        *)
            ;;
    esac

    ./configure "${CONFIGURE_OPTS[@]}"

    make
    make install
}

run "$@"
