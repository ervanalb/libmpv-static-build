# libmpv static build

Scripts for building libmpv as a static library with GPL features removed.

Supported targets:
- [X] x86_64-unknown-linux-gnu (Desktop Linux)
- [X] x86_64-pc-windows-gnu (Windows)
- [ ] arm64-apple-macos11 (Apple silicon MacOS)
- [ ] x86_64-apple-macos10.12 (Intel MacOS)

Heavily inspired by https://github.com/shinchiro/mpv-winbuild-cmake/ and https://github.com/zhongfly/mpv-winbuild/

## Usage

This is meant to be used from CI for clean builds,
so there aren't so many incremental build options.

### Clean

```bash
rm -rf fetch/ downloads/ x86_64-unknown-linux-gnu/ x86_64-pc-windows-gnu/
```

### Download all source packages

Downloads will use `fetch/` as a working directory
and `downloads/` for the final results

```bash
scripts/all.sh download
# or download a single package using, e.g.: scripts/zstd.sh download
```

### Build all libraries

Builds will use `$TARGET/work/` as a working directory
and `$TARGET/output/` for the final results

```bash
export TARGET=x86_64-pc-windows-gnu
scripts/all.sh build
# or build a single package using, e.g.: scripts/zstd.sh download
```
