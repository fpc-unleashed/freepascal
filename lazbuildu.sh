#!/bin/sh
# Wrapper for building Lazarus projects with the in-tree FPC Unleashed
# compiler: runs lazbuild with --compiler pointing at fpcu.sh.
FP="$(cd "$(dirname "$0")" && pwd)"
# LAZ="${LAZDIR:-$FP/../lazarus}"
# if [ ! -x "$LAZ/lazbuild" ]; then
#  echo "lazbuildu.sh: no lazbuild binary at $LAZ/lazbuild" >&2
#  echo "build Lazarus there first, or point LAZDIR at a Lazarus directory" >&2
#  exit 2
# fi
exec "lazbuild" --compiler="$FP/fpcu.sh" "$@"
