set -euo pipefail

BASE="$(cd "$(dirname "$0")/.." && pwd)"
DOWNLOADS_BASE="${BASE}/downloads"
WORK_BASE="${BASE}/work"
OUTPUT_BASE="${BASE}/output"
FETCH_BASE="${BASE}/fetch"
PATCH_BASE="${BASE}/patches"

export PKG_CONFIG_SYSROOT_DIR="$OUTPUT_BASE"

SOURCE_ARCHIVE="$PKGNAME-$PKGVER.tar.gz"
WORK="$WORK_BASE/$PKGNAME-$PKGVER"
FETCH="$FETCH_BASE/$PKGNAME-$PKGVER"

run() {
    ACTION="${1:-}"
    case "$ACTION" in
        download)
            echo "Downloading ${PKGNAME}"
            download
            ;;
        build)
            echo "Building ${PKGNAME}"
            build
            ;;
        *)
            echo "Usage: $(basename $0) {download|build}" >&2
            exit 1
            ;;
    esac
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

TARGET_CPU_FAMILY="x86_64"
TARGET_ARCH="x86_64-w64-mingw32"

GCC_LIBDIR="$($TARGET_ARCH-g++ -print-file-name=libgcc.a | xargs dirname)"
GCC_INCLUDE_CXX="$GCC_LIBDIR/include/c++"
GCC_INCLUDE_CXX_TARGET="$GCC_LIBDIR/include/c++/$TARGET_ARCH"
GCC_INCLUDE_CXX_BACKWARD="$GCC_LIBDIR/include/c++/backward"

generate_meson_cross() {
    cat <<EOF > meson_cross.txt
[binaries]
c = ['clang', '--target=$TARGET_ARCH']
cpp = ['clang++', '--target=$TARGET_ARCH']
ar = 'x86_64-w64-mingw32-ar'
ranlib = 'x86_64-w64-mingw32-ranlib'
strip = 'x86_64-w64-mingw32-strip'
windres = 'x86_64-w64-mingw32-windres'
pkg-config = 'pkg-config'

[built-in options]
c_args = ['-I$OUTPUT_BASE/include']
cpp_args = ['-isystem', '$GCC_INCLUDE_CXX', '-isystem', '$GCC_INCLUDE_CXX_TARGET', '-isystem', '$GCC_INCLUDE_CXX_BACKWARD', '-I$OUTPUT_BASE/include']
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
    cat <<EOF > toolchain.cmake
SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_SYSTEM_PROCESSOR $TARGET_CPU_FAMILY)

SET(CMAKE_C_COMPILER clang)
SET(CMAKE_CXX_COMPILER clang++)
SET(CMAKE_C_COMPILER_TARGET $TARGET_ARCH)
SET(CMAKE_CXX_COMPILER_TARGET $TARGET_ARCH)
SET(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)
SET(CMAKE_ASM_COMPILER clang)

SET(CMAKE_C_FLAGS_INIT "--target=$TARGET_ARCH")
SET(CMAKE_CXX_FLAGS_INIT "--target=$TARGET_ARCH \
-isystem $GCC_INCLUDE_CXX \
-isystem $GCC_INCLUDE_CXX_TARGET \
-isystem $GCC_INCLUDE_CXX_BACKWARD")
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
    cat <<EOF > cross.env
export MAKEFLAGS="-j $(nproc)"
export CC="clang --target=$TARGET_ARCH"
export CXX="clang++ --target=$TARGET_ARCH"
export LD="clang --target=$TARGET_ARCH -L$OUTPUT_BASE/lib -L/usr/$TARGET_ARCH/lib"

export CXXFLAGS="-isystem $GCC_INCLUDE_CXX \
-isystem $GCC_INCLUDE_CXX_TARGET \
-isystem $GCC_INCLUDE_CXX_BACKWARD"
export LDFLAGS="-pthread"
export AR=x86_64-w64-mingw32-ar
export RANLIB=x86_64-w64-mingw32-ranlib
export PKG_CONFIG=pkg-config
export PREFIX=$OUTPUT_BASE
export PKG_CONFIG_PATH=$OUTPUT_BASE/lib/pkgconfig
export PKG_CONFIG_LIBDIR=$OUTPUT_BASE/lib/pkgconfig
EOF
}
