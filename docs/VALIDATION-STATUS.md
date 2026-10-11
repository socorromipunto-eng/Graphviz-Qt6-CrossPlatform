# Validation status

Evidence date: 2026-10-11. Scope: Windows x64 only.

| Area | Verdict | Boundary |
| --- | --- | --- |
| Windows x64 configure | PASS | Existing CMake/MSVC project |
| GVEdit Release build | PASS | Exact binary hash in local evidence |
| dot + three plugins Release build | PASS | Exact binary hashes in local evidence |
| Dynamic plugin registration | PASS | Generated config8; three plugin entries |
| DOT to PNG runtime | PASS | dot exit 0, 586x98 px, 8227 bytes |
| GVEdit visual smoke test | USER_OBSERVED_PASS | Diagram reportedly displayed; no automated screenshot attestation |
| Windows ARM64 native | PENDING | No native execution evidence here |
| macOS x86_64 / arm64 | PENDING | Build and runtime evidence absent here |
| Install/packaging/license assessment | PENDING | No redistributable artifact |

PNG SHA256: `FCA68E90F3FD27630F20073D34342CCCADC24124CC16B68ABCC914E2D789A6A4`.

This status is not certification or a cross-platform completion claim.