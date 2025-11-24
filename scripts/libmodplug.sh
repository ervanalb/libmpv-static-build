#!/bin/bash
set -euo pipefail

PKGNAME="libmodplug"
PKGVER="0.8.9.0"
SOURCE_ARCHIVE_SHA256="457ca5a6c179656d66c01505c0d95fafaead4329b9dbaa0f997d00a3508ad9de"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://sourceforge.net/projects/modplug-xmms/files/libmodplug/${PKGVER}/${SOURCE_ARCHIVE}/download"
}

build() {
    extract
    setup_output

    cd "$WORK"

    CXXFLAGS="-std=c++11"
    generate_cross_env
    . cross.env

    ./configure \
        --host=${TARGET_ARCH} \
        --prefix=${OUTPUT_BASE} \
        --disable-shared \
        --enable-static

    make
    make install

    # Write corrected libmodplug.pc file with MODPLUG_STATIC define
    cat > "${OUTPUT_BASE}/lib/pkgconfig/libmodplug.pc" <<EOF
prefix=${OUTPUT_BASE}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: libmodplug
Description: The ModPlug mod file playing library.
Version: ${PKGVER}
Libs: -L\${libdir} -lmodplug
Libs.private: -lstdc++ -lm
Cflags: -I\${includedir}
Cflags.private: -DMODPLUG_STATIC
EOF
}

run "$@"
