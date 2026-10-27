#!/usr/bin/env bash
# Runs inside the emscripten/emsdk container (see build.sh and the CI workflow). Builds a single-thread, SIMD, classical-eval
# Rapfi for the browser. The NNUE networks are ~10 MB each, so they are left out on purpose; the classical model is ~60 kB.
set -euo pipefail

SRC=/tmp/src
NET=rapfi/Networks
rm -rf "$SRC" /tmp/build
mkdir -p "$SRC/Networks/config-example" "$SRC/Networks/classical"
cp -r rapfi/Rapfi "$SRC/Rapfi"
cp "$NET/config-example/gomocalc-classical260809.toml" "$SRC/Networks/config-example/"
cp "$NET/classical/model260809.bin" "$SRC/Networks/classical/"
# What Rapfi's CMake preloads into the wasm virtual file system (src@dest, relative to Networks/).
cat > "$SRC/Networks/wasm_preloads.txt" <<'EOF'
config-example/gomocalc-classical260809.toml@/config.toml
classical/model260809.bin@/model260809.bin
EOF

cd "$SRC/Rapfi"
# ES module output (default export = the Rapfi factory), so a module Web Worker can import it.
sed -i 's/-s MODULARIZE=1 /-s MODULARIZE=1 -s EXPORT_ES6=1 /' CMakeLists.txt
grep -q 'EXPORT_ES6=1' CMakeLists.txt
emcmake cmake -S . -B /tmp/build -DCMAKE_BUILD_TYPE=Release -DNO_COMMAND_MODULES=ON -DUSE_WASM_SIMD=ON -DNO_MULTI_THREADING=ON
cmake --build /tmp/build -j"$(nproc)"

cd - >/dev/null
rm -rf dist && mkdir -p dist
find /tmp/build -maxdepth 2 -type f \( -name 'rapfi*.js' -o -name 'rapfi*.wasm' -o -name 'rapfi*.data' \) -exec cp -v {} dist/ \;
ls -l dist
