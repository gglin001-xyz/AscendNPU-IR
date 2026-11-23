#!/usr/bin/env bash
# Build BiShengIR against the existing llvm-ascend LLVM/MLIR build tree.
# Usage: build-llvm-ascend.sh [--target <target> ...]
# LLVM_BUILD_DIR and BUILD_DIR override the dependency and output directories.
set -euo pipefail

# git@github.com:gglin001-xyz/llvm-ascend.git

root=$(cd "$(dirname "$0")/.." && pwd)
llvm_build=${LLVM_BUILD_DIR:-"$root/llvm-ascend/llvm-project/build"}
build_dir=${BUILD_DIR:-"$root/build-llvm-ascend"}

if [[ ! -f "$llvm_build/lib/cmake/llvm/LLVMConfig.cmake" ||
      ! -f "$llvm_build/lib/cmake/mlir/MLIRConfig.cmake" ]]; then
  echo "Missing LLVM/MLIR build in $llvm_build. Build llvm-ascend or set LLVM_BUILD_DIR." >&2
  exit 1
fi

export CC=${CC:-clang} CXX=${CXX:-clang++}
cmake -S "$root" -B "$build_dir" -G Ninja \
  -DLLVM_DIR="$llvm_build/lib/cmake/llvm" \
  -DMLIR_DIR="$llvm_build/lib/cmake/mlir" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DBISHENGIR_ENABLE_TRITON_COMPILE=ON \
  -DBISHENGIR_ENABLE_PM_CL_OPTIONS=ON \
  -DBISHENGIR_PUBLISH=ON
cmake --build "$build_dir" --parallel "${CMAKE_BUILD_PARALLEL_LEVEL:-64}" "$@"
