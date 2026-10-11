# Graphviz + Qt 6 cross-platform build engineering

Initial **Windows x64 validation milestone**. This repository starts with an original reproducibility checklist, a DOT smoke test, and a PowerShell runtime test. It is **not** a claim of production-ready packaging or complete cross-platform support.

## Verified scope (2026-10-11)

- Windows x64: Graphviz `dot.exe` and GVEdit built with MSVC; Qt 6 GUI opened.
- Dynamic plugins (`core`, `dot_layout`, `gdiplus`) registered in `config8`.
- `dot -Kdot -Tpng` produced a valid 586x98 PNG, SHA256 recorded in docs.
- User confirmed that the diagram was displayed inside GVEdit; this is a manual observation, not an automated E2E GUI assertion.

## Not yet verified

Windows ARM64 **native runtime**, macOS x86_64, macOS arm64, redistributable bundles, clean-machine installation, complete dependency licensing, and CI are **pending**.

## Quick smoke test

With Graphviz already available, run `dot -Kdot -Tpng examples/hello.gv -o hello.png`.
For explicit binaries/plugins on Windows, use `scripts/Test-GraphvizRuntime.ps1 -BinDir <directory> -OutputDir <empty-directory>`.

No upstream Graphviz or Qt source code, binaries, SDKs, installed dependencies, private machine paths, or private build evidence are included in this public candidate.
See `docs/VALIDATION-STATUS.md`, `docs/REPRODUCIBILITY-GAPS.md` and `NOTICE.md`.