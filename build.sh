#!/usr/bin/env bash
# Local build through Docker (needs Docker running). CI does the same in .github/workflows/build.yml.
set -euo pipefail
git submodule update --init --depth 1 rapfi
git -C rapfi submodule update --init --depth 1 Networks
docker run --rm -v "$PWD":/work -w /work emscripten/emsdk:3.1.74 bash scripts/build-in-container.sh
