# Reproducibility and release gaps

1. Replace workstation-specific Windows paths with parameterized toolchain discovery.
2. Lock source commit, toolchain, dependencies, and every relevant license notice in a portable manifest.
3. Create clean Windows x64 CI build and functional GUI smoke-test automation.
4. Validate Windows ARM64 on actual ARM64 hardware or a clearly documented equivalent runtime.
5. Execute macOS x86_64 and arm64 builds on real macOS runners and verify Qt GUI operation.
6. Package Qt platform plugins, Graphviz plugins, the correct `config8` (derived, not hardcoded), and required redistributables, then verify transitive DLLs and licenses.
7. Run clean-machine installation/uninstallation, E2E drawing, PNG export, and independent evidence capture.
8. Approve all third-party redistribution terms before any binary release.

Do not interpret this initial docs/example repository as an end-to-end build system for every platform.