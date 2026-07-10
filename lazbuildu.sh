#!/bin/sh
# Wrapper for building Lazarus projects with the in-tree FPC Unleashed
# compiler: runs lazbuild with --compiler pointing at fpcu.sh.
FP="$(cd "$(dirname "$0")" && pwd)"
# Resolve dependency packages (lazutils, freetype, ...) from the sibling
# Lazarus checkout, not from the system Lazarus install: the system install's
# shipped PPUs were built with the system FPC and are read-only, so mixing
# them with the in-tree compiler fails with "PPU Invalid Version".
LAZ="${LAZDIR:-$FP/../lazarus}"
if [ -d "$LAZ" ]; then
  set -- --lazarusdir="$LAZ" "$@"
fi
exec "lazbuild" --compiler="$FP/fpcu.sh" "$@"
