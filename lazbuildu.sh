#!/bin/sh
# Wrapper for building Lazarus projects with the in-tree FPC Unleashed
# compiler: runs lazbuild with --compiler pointing at fpcu.sh. Uses the
# lazbuild of the sibling ../lazarus checkout by default; override with
# LAZDIR=/path/to/lazarus. The Lazarus tree (LCL) must itself be built with
# this compiler, or lazbuild will rebuild it on first use. No optimization
# flags are added - the project's build mode decides (put -O4 in release
# modes to enable the fork's extra optimizer passes).
FP="$(cd "$(dirname "$0")" && pwd)"
LAZ="${LAZDIR:-$FP/../lazarus}"
if [ ! -x "$LAZ/lazbuild" ]; then
  echo "lazbuildu.sh: no lazbuild binary at $LAZ/lazbuild" >&2
  echo "build Lazarus there first, or point LAZDIR at a Lazarus directory" >&2
  exit 2
fi
exec "$LAZ/lazbuild" --compiler="$FP/fpcu.sh" "$@"
