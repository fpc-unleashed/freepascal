#!/bin/sh
# Wrapper for the in-tree FPC Unleashed compiler. Compiles with -O4 so the
# fork's extra optimizer passes run; flags passed on the command line come
# last and therefore override the defaults (e.g. ./fpc.sh -O1 test.pas).
FP="$(cd "$(dirname "$0")" && pwd)"
exec "$FP/compiler/ppcx64" -O4 \
  "-Fu$FP/rtl/units/x86_64-linux" \
  "-Fu$FP/packages/*/units/x86_64-linux" \
  "$@"
