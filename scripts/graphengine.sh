#!/bin/bash
set -euo pipefail

PKGNAME="graphengine"
PKGVER="d2bd76381b21a80f7005b913e4b2121f7787de11"

source "$(dirname "$0")/common.sh"

download() {
    GIT_CLONE_FLAGS="--no-checkout"
    fetch_git "https://bitbucket.org/the-sekrit-twc/graphengine.git"

    cd "$FETCH"
    git checkout ${PKGVER}

    create_tarball
}

build() {
    # graphengine is header-only, no build needed
    # It will be used as a submodule by libzimg
    :
}

run "$@"
