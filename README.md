# rapfi-wasm

[Rapfi](https://github.com/dhbloo/rapfi) (the Gomocup-winning gomoku engine) built for the browser with Emscripten, for the caro game
in [hoan02/game-hub](https://github.com/hoan02/game-hub).

This repository only holds the build recipe; the engine source is the `rapfi` submodule (GPL-3.0, see `LICENSE`). Built files are
GPL-3.0 as well, and this repository is their corresponding source.

## What it builds

Single thread, WebAssembly SIMD, **classical evaluation only** (`model260809.bin`, about 60 kB, CC0 from
[rapfi-networks](https://github.com/dhbloo/rapfi-networks)). The NNUE networks are about 10 MB each, far above a game's asset budget, so
they are not included. The config is `gomocalc-classical260809.toml`.

Output in `dist/`: `rapfi*.js` (a `Rapfi` module factory), `rapfi*.wasm`, `rapfi*.data` (preloaded config and model).

## Build

CI (`.github/workflows/build.yml`) builds on every push and uploads `dist/` as an artifact, and prints the gzip size of each file.
Locally, with Docker running: `bash build.sh`.

## Using it

Rapfi talks the Piskvork protocol over `Module.sendCommand(...)` and `Module.onReceiveStdout(...)` (see
`rapfi/Rapfi/emscripten/preamble.js`). Run it in a Web Worker; the first reply to `START 15` is `OK`, then `BOARD ... DONE` or
`TURN x,y` answers with `x,y`.

## Status

Not built or measured yet. Open questions: size of the wasm and data files, start-up time, time per move on a phone.
