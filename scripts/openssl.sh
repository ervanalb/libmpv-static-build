#!/bin/bash
set -euo pipefail

PKGNAME="openssl"
PKGVER="3.6.0"
SOURCE_ARCHIVE_SHA256="b6a5f44b7eb69e3fa35dbf15524405b44837a481d43d81daddde3ff21fcbb8e9"

source "$(dirname "$0")/common.sh"

download() {
    fetch_url "https://github.com/openssl/openssl/releases/download/openssl-${PKGVER}/${SOURCE_ARCHIVE}"
}

build() {
    extract;
    setup_output;

    cd "$WORK"

    generate_cross_env;
    . cross.env

    ./Configure \
        --prefix=${OUTPUT_BASE} \
        --libdir=lib \
        --release \
        mingw64 \
        no-autoload-config \
        -I${OUTPUT_BASE}/include \
        no-ssl3-method \
        enable-brotli \
        no-whirlpool \
        no-filenames \
        no-camellia \
        enable-zstd \
        no-capieng \
        no-shared \
        no-rmd160 \
        no-module \
        no-legacy \
        no-tests \
        threads \
        no-docs \
        no-apps \
        no-ocsp \
        no-ssl3 \
        no-cmac \
        no-mdc2 \
        no-idea \
        no-cast \
        no-seed \
        no-aria \
        no-err \
        no-dso \
        no-dsa \
        no-srp \
        no-rc2 \
        no-rc4 \
        no-sm2 \
        no-sm3 \
        no-sm4 \
        no-md4 \
        no-cms \
        no-cmp \
        no-dh \
        no-bf \
        zlib


    make build_sw
    make install_sw
}

run "$@"
