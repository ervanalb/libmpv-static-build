# libmpv static build

Scripts for building libmpv as a static library with GPL features removed.

Supported targets:
- [X] x86_64-w64-mingw32 (Windows)
- [ ] x86_64-linux-gnu (Desktop Linux)
- [ ] arm64-apple-macos11 (Apple silicon MacOS)
- [ ] x86_64-apple-macos10.12 (Intel MacOS)

Heavily inspired by https://github.com/shinchiro/mpv-winbuild-cmake/ and https://github.com/zhongfly/mpv-winbuild/

## Usage

This is meant to be used from CI for clean builds,
so there aren't so many incremental build options.

### Clean

```bash
rm -rf fetch/ downloads/ work/ output/
```

### Download all source packages

Downloads will use `fetch/` as a working directory
and `downloads/` for the final results

```bash
scripts/all.sh download
# or download a single package using, e.g.: scripts/zstd.sh download
```

### Build all libraries

Builds will use `work/` as a working directory
and `output/` for the final results

```bash
scripts/all.sh build
# or build a single package using, e.g.: scripts/zstd.sh download
```
