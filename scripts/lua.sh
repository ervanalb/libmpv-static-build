#!/bin/bash
set -euo pipefail

PKGNAME="lua"
PKGVER="5.2.4"
SOURCE_ARCHIVE_SHA256="b9e2e4aad6789b3b63a056d442f7b39f0ecfca3ae0f1fc0ae4e9614401b69f4b"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://www.lua.org/ftp/lua-${PKGVER}.tar.gz"
}

build() {
    extract
    setup_output

    cd "$WORK"

    generate_cross_env
    source cross.env

    # Build static library only (no executables needed)
    cd src
    make \
        CC="$CC" \
        AR="$AR rcu" \
        RANLIB="$RANLIB" \
        MYCFLAGS="-DLUA_COMPAT_5_3" \
        SYSLIBS="" \
        liblua.a

    # Install manually
    mkdir -p "${OUTPUT_BASE}/include"
    mkdir -p "${OUTPUT_BASE}/lib"

    # Install headers
    install -p -m 0644 lua.h "${OUTPUT_BASE}/include/"
    install -p -m 0644 luaconf.h "${OUTPUT_BASE}/include/"
    install -p -m 0644 lualib.h "${OUTPUT_BASE}/include/"
    install -p -m 0644 lauxlib.h "${OUTPUT_BASE}/include/"
    install -p -m 0644 lua.hpp "${OUTPUT_BASE}/include/"

    # Install library
    install -p -m 0644 liblua.a "${OUTPUT_BASE}/lib/"

    # Create pkg-config file
    cat > "${OUTPUT_BASE}/lib/pkgconfig/lua.pc" <<EOF
prefix=${OUTPUT_BASE}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: Lua
Description: An Extensible Extension Language
Version: ${PKGVER}
Libs: -L\${libdir} -llua -lm
Cflags: -I\${includedir}
EOF
}

run "$@"
