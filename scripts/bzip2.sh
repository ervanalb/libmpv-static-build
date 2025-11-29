#!/bin/bash
set -euo pipefail

PKGNAME="bzip2"
PKGVER="1.0.8"
SOURCE_ARCHIVE_SHA256="db106b740252669664fd8f3a1c69fe7f689d5cd4b132f82ba82b9afba27627df"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/libarchive/bzip2/archive/refs/tags/${PKGNAME}-${PKGVER}.tar.gz"
}

build() {
    extract;
    setup_output;
    cd "$WORK"

    generate_cross_env;
    . cross.env
    make libbz2.a CC="$CC" AR="$AR" RANLIB="$RANLIB" PREFIX="$PREFIX" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"

    # Install
    mkdir -p "$OUTPUT_BASE/include"
	cp -f bzlib.h $OUTPUT_BASE/include
	chmod a+r $OUTPUT_BASE/include/bzlib.h
    mkdir -p "$OUTPUT_BASE/lib"
	cp -f libbz2.a $OUTPUT_BASE/lib
	chmod a+r $OUTPUT_BASE/lib/libbz2.a

    # Create pkg-config file
    mkdir -p "$OUTPUT_BASE/lib/pkgconfig"
    cat > "$OUTPUT_BASE/lib/pkgconfig/bzip2.pc" <<EOF
prefix=$OUTPUT_BASE
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: bzip2
Description: A high-quality data compressor
Version: $PKGVER
Libs: -L\${libdir} -lbz2
Cflags: -I\${includedir}
EOF
}

run "$@"
