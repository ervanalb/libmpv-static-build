set -euo pipefail

BASE="$(cd "$(dirname "$0")/.." && pwd)"

DOWNLOADS_BASE="${BASE}/downloads"
FETCH_BASE="${BASE}/fetch"
PATCH_BASE="${BASE}/patches"

SOURCE_ARCHIVE="$PKGNAME-$PKGVER.tar.gz"
FETCH="$FETCH_BASE/$PKGNAME-$PKGVER"

run() {
    ACTION="${1:-}"
    case "$ACTION" in
        download)
            echo "Downloading ${PKGNAME}"
            download
            ;;
        build)
            case "$TARGET" in
              "x86_64-pc-windows-gnu")
                TARGET_CPU_FAMILY="x86_64"
                TARGET_ARCH="x86_64-w64-mingw32"
                TOOLCHAIN_PREFIX="$TARGET_ARCH-"
                OS="WIN32"
                ;;
              *)
                echo "ERROR: Bad TARGET variable. Available targets:" >&2
                echo "  * x86_64-pc-windows-gnu" >&2
                exit 1
                ;;
            esac

            _build_common

            echo "Building ${PKGNAME} for ${TARGET}"
            build
            ;;
        *)
            echo "Usage: $(basename $0) {download|build}" >&2
            exit 1
            ;;
    esac
}

_build_common() {
    TARGET_BASE="${BASE}/${TARGET}"
    WORK_BASE="${TARGET_BASE}/work"
    WORK="$WORK_BASE/$PKGNAME-$PKGVER"
    OUTPUT_BASE="${TARGET_BASE}/output"
    export PKG_CONFIG_SYSROOT_DIR="$OUTPUT_BASE"

    GCC_LIBDIR="$($TARGET_ARCH-g++ -print-file-name=libgcc.a | xargs dirname)"
    GCC_INCLUDE_CXX="$GCC_LIBDIR/include/c++"
    GCC_INCLUDE_CXX_TARGET="$GCC_LIBDIR/include/c++/$TARGET_ARCH"
    GCC_INCLUDE_CXX_BACKWARD="$GCC_LIBDIR/include/c++/backward"

    # Common compiler flags (append to existing CFLAGS/CXXFLAGS if set)
    BASE_CFLAGS="-pthread -I$OUTPUT_BASE/include"
    BASE_CXXFLAGS="-pthread -isystem $GCC_INCLUDE_CXX -isystem $GCC_INCLUDE_CXX_TARGET -isystem $GCC_INCLUDE_CXX_BACKWARD -I$OUTPUT_BASE/include"
}

fetch_url() {
    URL="$1"

    mkdir -p "$DOWNLOADS_BASE"

    if ! already_downloaded; then
        curl --progress-bar --fail-with-body -L "$1" -o "$DOWNLOADS_BASE/$SOURCE_ARCHIVE-unverified"
        verify
    fi
}

fetch_git() {
    URL="$1"
    GIT_CLONE_FLAGS="${GIT_CLONE_FLAGS:-}"
    rm -rf "$FETCH"
    git clone -q "$URL" "$FETCH" $GIT_CLONE_FLAGS
}

create_tarball() {
    tar -zcf "$DOWNLOADS_BASE/$SOURCE_ARCHIVE" --exclude .git --transform="s,^,$PKGNAME-$PKGVER/," .
}

verify() {
    echo "$SOURCE_ARCHIVE_SHA256 $DOWNLOADS_BASE/$SOURCE_ARCHIVE-unverified" | sha256sum --check --status \
        || { echo "Error: checksum failed for $SOURCE_ARCHIVE" >&2; exit 1; }
    mv "$DOWNLOADS_BASE/$SOURCE_ARCHIVE-unverified" "$DOWNLOADS_BASE/$SOURCE_ARCHIVE"
}

already_downloaded() {
    echo "$SOURCE_ARCHIVE_SHA256 $DOWNLOADS_BASE/$SOURCE_ARCHIVE" | sha256sum --check --status 2>/dev/null
    RC=$?
    if [ $RC -eq 0 ]; then
        echo "$PKGNAME already downloaded"
    else
        rm -f "$SOURCE_ARCHIVE_SHA256 $DOWNLOADS_BASE/$SOURCE_ARCHIVE"
    fi
    return $RC
}

extract() {
    rm -rf "$WORK"
    mkdir -p "$WORK"
    tar -xf "$DOWNLOADS_BASE/$SOURCE_ARCHIVE" --strip-components 1 -C "$WORK"
}

setup_output() {
    mkdir -p "${OUTPUT_BASE}"
}

meson_ninja_remove_invalid_linker_args() {
    BUILDDIR="${1:-.}"
    sed -i 's/-Wl,--allow-shlib-undefined//g' "$BUILDDIR/build.ninja"
}

patch_meson_iconv_dependency() {
    # Patch meson.build to use iconv_ instead of iconv to avoid built-in detection
    sed -i "s/dependency('iconv'/dependency('iconv_'/g" meson.build
}

_format_meson_array() {
    local result=""
    for arg in "$@"; do
        if [ -n "$result" ]; then
            result="$result, "
        fi
        result="$result'$arg'"
    done
    echo "$result"
}

generate_meson_cross() {
    CFLAGS="$BASE_CFLAGS${CFLAGS:+ $CFLAGS}"
    CXXFLAGS="$BASE_CXXFLAGS${CXXFLAGS:+ $CXXFLAGS}"

    CFLAGS_ARRAY=($CFLAGS)
    CXXFLAGS_ARRAY=($CXXFLAGS)

    CFLAGS_MESON=$(_format_meson_array "${CFLAGS_ARRAY[@]}")
    CXXFLAGS_MESON=$(_format_meson_array "${CXXFLAGS_ARRAY[@]}")

    WINDRES=""
    if [[ "$OS" == "WIN32" ]]; then
        WINDRES="windres = '${TOOLCHAIN_PREFIX}windres'"
    fi

    cat <<EOF > meson_cross.txt
[binaries]
c = ['clang', '--target=$TARGET_ARCH']
cpp = ['clang++', '--target=$TARGET_ARCH']
ar = '${TOOLCHAIN_PREFIX}ar'
ranlib = '${TOOLCHAIN_PREFIX}ranlib'
strip = '${TOOLCHAIN_PREFIX}strip'
${WINDRES}
pkg-config = 'pkg-config'

[built-in options]
c_args = [$CFLAGS_MESON]
cpp_args = [$CXXFLAGS_MESON]
c_link_args = ['-L$OUTPUT_BASE/lib', '-pthread']
cpp_link_args = ['-L$OUTPUT_BASE/lib', '-pthread']

[properties]
pkg_config_libdir = '$OUTPUT_BASE/lib/pkgconfig'
pkg_config_path = '$OUTPUT_BASE/lib/pkgconfig'

[host_machine]
system = 'windows'
cpu_family = '$TARGET_CPU_FAMILY'
cpu = '$TARGET_ARCH'
endian = 'little'
EOF
}

generate_cmake_toolchain_file() {
    CFLAGS="$BASE_CFLAGS${CFLAGS:+ $CFLAGS}"
    CXXFLAGS="$BASE_CXXFLAGS${CXXFLAGS:+ $CXXFLAGS}"

    WINDRES=""
    if [[ "$OS" == "WIN32" ]]; then
        WINDRES="SET(CMAKE_RC_COMPILER ${TOOLCHAIN_PREFIX}windres)"
    fi

    cat <<EOF > toolchain.cmake
SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_SYSTEM_PROCESSOR $TARGET_CPU_FAMILY)

SET(CMAKE_C_COMPILER clang)
SET(CMAKE_CXX_COMPILER clang++)
SET(CMAKE_C_COMPILER_TARGET $TARGET_ARCH)
SET(CMAKE_CXX_COMPILER_TARGET $TARGET_ARCH)
${WINDRES}
SET(CMAKE_ASM_COMPILER clang)

SET(CMAKE_C_FLAGS_INIT "--target=$TARGET_ARCH $CFLAGS")
SET(CMAKE_CXX_FLAGS_INIT "--target=$TARGET_ARCH $CXXFLAGS")
SET(CMAKE_EXE_LINKER_FLAGS_INIT "-L/usr/$TARGET_ARCH/lib -pthread")
SET(CMAKE_SHARED_LINKER_FLAGS_INIT "-L/usr/$TARGET_ARCH/lib -pthread")
SET(CMAKE_MODULE_LINKER_FLAGS_INIT "-L/usr/$TARGET_ARCH/lib -pthread")

SET(CMAKE_FIND_ROOT_PATH $OUTPUT_BASE /usr/$TARGET_ARCH)
SET(CMAKE_INSTALL_PREFIX $OUTPUT_BASE)

SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET(ENV{PKG_CONFIG_PATH} "$OUTPUT_BASE/lib/pkgconfig")
SET(ENV{PKG_CONFIG_LIBDIR} "$OUTPUT_BASE/lib/pkgconfig")
EOF
}

generate_cross_env() {
    CFLAGS="$BASE_CFLAGS${CFLAGS:+ $CFLAGS}"
    CXXFLAGS="$BASE_CXXFLAGS${CXXFLAGS:+ $CXXFLAGS}"

    cat <<EOF > cross.env
export MAKEFLAGS="-j $(nproc)"
export CC="clang --target=$TARGET_ARCH"
export CXX="clang++ --target=$TARGET_ARCH"
export LD="clang --target=$TARGET_ARCH -L$OUTPUT_BASE/lib -L/usr/$TARGET_ARCH/lib"

export CFLAGS="$CFLAGS"
export CXXFLAGS="$CXXFLAGS"
export LDFLAGS="-pthread"
export AR=${TOOLCHAIN_PREFIX}ar
export RANLIB=${TOOLCHAIN_PREFIX}ranlib
export PKG_CONFIG=pkg-config
export PREFIX=$OUTPUT_BASE
export PKG_CONFIG_PATH=$OUTPUT_BASE/lib/pkgconfig
export PKG_CONFIG_LIBDIR=$OUTPUT_BASE/lib/pkgconfig
EOF
}
