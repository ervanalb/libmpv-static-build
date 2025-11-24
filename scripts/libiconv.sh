#!/bin/bash
set -euo pipefail

PKGNAME="libiconv"
PKGVER="1.18"
SOURCE_ARCHIVE_SHA256="3b08f5f4f9b4eb82f151a7040bfd6fe6c6fb922efe4b1659c66ea933276965e8"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://mirrors.dotsrc.org/gnu/libiconv/${SOURCE_ARCHIVE}"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Set up environment for cross-compilation
    generate_cross_env
    . cross.env

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-nls \
        --disable-shared \
        --enable-extra-encodings

    make
    make install

    # Rename .lib to .a (Windows only)
    if [[ "$OS" == "WINDOWS" ]]; then
        mv "${OUTPUT_BASE}/lib/libiconv.lib" "${OUTPUT_BASE}/lib/libiconv.a"
        mv "${OUTPUT_BASE}/lib/libcharset.lib" "${OUTPUT_BASE}/lib/libcharset.a"
    fi

    # Create pkg-config file with underscore to avoid Meson's built-in detection
    cat > "${OUTPUT_BASE}/lib/pkgconfig/iconv_.pc" <<EOF
prefix=${OUTPUT_BASE}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: iconv
Description: Character set conversion library
Version: ${PKGVER}
Libs: -L\${libdir} -liconv
Cflags: -I\${includedir}
EOF
}

run "$@"
