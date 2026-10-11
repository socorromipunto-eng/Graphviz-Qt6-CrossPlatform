# Windows x64 v0.2.1 validation record

Scope: Graphviz + Qt 6 Windows x64 only. This is a functional validation record, not a cross-platform release.

- Graphviz source HEAD: `e41c710710be080ad37af1b51c6e2f8beffa9ee5` (as checked in runner preflight).
- Qt: 6.12.0 MSVC2022 x64; toolchain: MSVC 2022; CMake: 3.30.0.
- Bison SHA256: `DB9602D654AC90D8CDAEA7E03E82A82AC6CFE13077EB7D1CA13FC788DD97712A`.
- Flex SHA256: `14C3741650BF31F1FA24213EABFAF0A84806346E4B6F257D16FB99B7A7966668`.
- Configure and build: PASS; target outputs: `gvedit.exe`, `dot.exe`, `gvplugin_core.dll`, `gvplugin_dot_layout.dll`, `gvplugin_gdiplus.dll`.
- Newly built gvedit SHA256: `4C9ED53CB5A97650294AC22FE370FF262B7EB38617803843700D4B4238687B71`.
- Newly built dot SHA256: `3A4B542D8AF5C7884E4D7F82B168BBB587B76B9F2AD9CB66108EB19AD025AD41`.
- Plugin registry: `config8` derived from generated `config.h`; registered core, dot_layout, gdiplus. PASS.
- Isolated DOT PNG rendering: PASS, 812x98, 13249 bytes, SHA256 `59FE6A29B9AA1D82755562209DC2518CEC1F22D66E8B8B04BB290EB79618AFB3`.
- GVEdit GUI visualization: PASS based on user's direct observation of a saved, rendered colored validation graph. No automated GUI regression test or screenshot attached.
- Windows ARM64 and macOS x86_64/arm64: NOT VALIDATED.

No external package binaries, private working paths or local machine evidence archives are committed by this record.