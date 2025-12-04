#!/bin/bash
set -euo pipefail

PKGNAME="libplacebo"
PKGVER="7.351.0"
LIBPLACEBO_SHA256="4efe1c8d4da3c61295eb5fdfa50e6037409d8425eb3c15dd86788679c4ce59ee"
LIBPLACEBO_URL="https://code.videolan.org/videolan/libplacebo/-/archive/v${PKGVER}/libplacebo-v${PKGVER}.tar.gz"

GLAD_VER="2.0.8"
GLAD_SHA256="44f06f9195427c7017f5028d0894f57eb216b0a8f7c4eda7ce883732aeb2d0fc"
GLAD_URL="https://github.com/Dav1dde/glad/archive/refs/tags/v${GLAD_VER}.tar.gz"

FAST_FLOAT_VER="8.1.0"
FAST_FLOAT_SHA256="4bfabb5979716995090ce68dce83f88f99629bc17ae280eae79311c5340143e1"
FAST_FLOAT_URL="https://github.com/fastfloat/fast_float/archive/refs/tags/v${FAST_FLOAT_VER}.tar.gz"

source "$(dirname "$0")/common.sh"

download() {
    rm -rf "$FETCH"
    mkdir -p "$FETCH"
    cd "$FETCH"

    # Download libplacebo
    wget -q "$LIBPLACEBO_URL" -O "libplacebo-${PKGVER}.tar.gz-unverified"
    echo "$LIBPLACEBO_SHA256  libplacebo-${PKGVER}.tar.gz-unverified" | sha256sum_check \
        || { echo "Error: checksum failed for libplacebo-${PKGVER}.tar.gz" >&2; exit 1; }
    mv "libplacebo-${PKGVER}.tar.gz-unverified" "libplacebo-${PKGVER}.tar.gz"

    # Download glad
    wget -q "$GLAD_URL" -O "glad-${GLAD_VER}.tar.gz-unverified"
    echo "$GLAD_SHA256  glad-${GLAD_VER}.tar.gz-unverified" | sha256sum_check \
        || { echo "Error: checksum failed for glad-${GLAD_VER}.tar.gz" >&2; exit 1; }
    mv "glad-${GLAD_VER}.tar.gz-unverified" "glad-${GLAD_VER}.tar.gz"

    # Download fast_float
    wget -q "$FAST_FLOAT_URL" -O "fast_float-${FAST_FLOAT_VER}.tar.gz-unverified"
    echo "$FAST_FLOAT_SHA256  fast_float-${FAST_FLOAT_VER}.tar.gz-unverified" | sha256sum_check \
        || { echo "Error: checksum failed for fast_float-${FAST_FLOAT_VER}.tar.gz" >&2; exit 1; }
    mv "fast_float-${FAST_FLOAT_VER}.tar.gz-unverified" "fast_float-${FAST_FLOAT_VER}.tar.gz"

    # Extract libplacebo
    mkdir -p "libplacebo-${PKGVER}"
    tar -xf "libplacebo-${PKGVER}.tar.gz" --strip-components=1 -C "$FETCH/libplacebo-${PKGVER}"

    # Extract glad into 3rdparty/glad
    tar -xf "glad-${GLAD_VER}.tar.gz" --strip-components=1 -C "libplacebo-${PKGVER}/3rdparty/glad"

    # Extract fast_float into 3rdparty/fast_float
    tar -xf "fast_float-${FAST_FLOAT_VER}.tar.gz" --strip-components=1 -C "libplacebo-${PKGVER}/3rdparty/fast_float"

    # Create combined tarball
    tar -zcf "$DOWNLOADS_BASE/$SOURCE_ARCHIVE" "$PKGNAME-$PKGVER"
}

build() {
    extract
    setup_output

    cd "$WORK"

    # Apply Python 3.13 compatibility patch
    patch -p1 < ${PATCH_BASE}/libplacebo-0001-fix-python313-elementtree.patch

    # Apply patch to remove vulkan stubs when vulkan is disabled
    patch -p1 < ${PATCH_BASE}/libplacebo-0002-remove-vulkan-stubs.patch

    generate_meson_cross

    # D3D11 is Windows-only
    case "$OS" in
        "LINUX")
            D3D11_OPT="-Dd3d11=disabled"
            ;;
        "WINDOWS")
            D3D11_OPT="-Dd3d11=enabled"
            ;;
        "MACOS")
            D3D11_OPT="-Dd3d11=disabled"
            ;;
    esac

    meson setup build \
        --prefix=${OUTPUT_BASE} \
        --libdir=${OUTPUT_BASE}/lib \
        --cross-file=meson_cross.txt \
        --default-library=static \
        ${D3D11_OPT} \
        -Dvulkan=disabled \
        -Ddebug=false \
        -Db_ndebug=true \
        -Doptimization=3 \
        -Ddemos=false

    ninja -C build
    ninja -C build install

    # Write corrected libplacebo.pc file
    case "$OS" in
        "LINUX")
            PL_HAS_D3D11=0
            PL_LIBS="-L\${libdir} -lplacebo"
            ;;
        "WINDOWS")
            PL_HAS_D3D11=1
            PL_LIBS="-L\${libdir} -lplacebo -lshlwapi -lversion"
            ;;
        "MACOS")
            PL_HAS_D3D11=0
            PL_LIBS="-L\${libdir} -lplacebo"
            ;;
    esac

    cat > "${OUTPUT_BASE}/lib/pkgconfig/libplacebo.pc" <<EOF
prefix=${OUTPUT_BASE}
includedir=\${prefix}/include
libdir=\${prefix}/lib

pl_has_d3d11=${PL_HAS_D3D11}
pl_has_dovi=1
pl_has_gl_proc_addr=1
pl_has_glslang=0
pl_has_lcms=1
pl_has_libdovi=0
pl_has_opengl=1
pl_has_shaderc=1
pl_has_vk_proc_addr=0
pl_has_vulkan=0
pl_has_xxhash=1

Name: libplacebo
Description: Reusable library for GPU-accelerated video/image rendering
Version: ${PKGVER}
Requires: shaderc >= 2019.1, spirv-cross-c-shared >= 0.29.0, lcms2 >= 2.9
Libs: ${PL_LIBS}
Cflags: -I\${includedir} -DPL_STATIC
EOF
}

run "$@"
