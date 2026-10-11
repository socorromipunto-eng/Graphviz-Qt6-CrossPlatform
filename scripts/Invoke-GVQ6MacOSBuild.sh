#!/bin/sh
# v0.2.0 candidate: macOS preflight/build runner; NOT tested on macOS.
# Usage: sh scripts/Invoke-GVQ6MacOSBuild.sh SOURCE BUILD QT_PREFIX [--execute]
set -eu
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  echo 'USAGE=script SOURCE_DIR BUILD_DIR QT_PREFIX [--execute]' >&2
  exit 2
fi
source_dir=$1
build_dir=$2
qt_prefix=$3
execute=${4:-}
[ -d "$source_dir" ] || { echo 'HOLD=SOURCE_DIRECTORY_MISSING' >&2; exit 1; }
[ -f "$source_dir/CMakeLists.txt" ] || { echo 'HOLD=SOURCE_CMAKE_MISSING' >&2; exit 1; }
[ -f "$qt_prefix/lib/cmake/Qt6/Qt6Config.cmake" ] || { echo 'HOLD=QT6_CONFIG_MISSING' >&2; exit 1; }
command -v cmake >/dev/null 2>&1 || { echo 'HOLD=CMAKE_MISSING' >&2; exit 1; }
command -v clang >/dev/null 2>&1 || { echo 'HOLD=CLANG_MISSING' >&2; exit 1; }
[ ! -e "$build_dir" ] || { echo 'HOLD=BUILD_DESTINATION_EXISTS' >&2; exit 1; }
case "$source_dir" in /*) ;; *) echo 'HOLD=SOURCE_MUST_BE_ABSOLUTE' >&2; exit 1;; esac
case "$build_dir" in /*) ;; *) echo 'HOLD=BUILD_MUST_BE_ABSOLUTE' >&2; exit 1;; esac
case "$qt_prefix" in /*) ;; *) echo 'HOLD=QT_PREFIX_MUST_BE_ABSOLUTE' >&2; exit 1;; esac
[ "$source_dir" != "$build_dir" ] || { echo 'HOLD=SOURCE_BUILD_COLLISION' >&2; exit 1; }
echo 'PLATFORM=macOS'
echo 'ARCHITECTURE=DETECTED_BY_HOST_NOT_ASSERTED'
echo "SOURCE=$source_dir"
echo "BUILD=$build_dir"
echo "QT_PREFIX=$qt_prefix"
if [ -z "$execute" ]; then
  echo 'RESULT=PASS_PREFLIGHT_NO_MUTATION'
  exit 0
fi
[ "$execute" = '--execute' ] || { echo 'HOLD=UNRECOGNIZED_ARGUMENT' >&2; exit 1; }
# Graphviz may require additional upstream packages; no automatic dependency installation.
cmake -S "$source_dir" -B "$build_dir" -G 'Unix Makefiles' -DCMAKE_PREFIX_PATH="$qt_prefix" -DWITH_GVEDIT=ON || { echo 'HOLD=CONFIGURE_FAILED'; exit 1; }
cmake --build "$build_dir" --config Release --target gvedit dot gvplugin_core gvplugin_dot_layout --parallel 2 || { echo 'HOLD=BUILD_FAILED'; exit 1; }
echo 'RESULT=PASS_BUILD_COMMANDS_EXIT_ZERO_RUNTIME_NOT_VALIDATED'
