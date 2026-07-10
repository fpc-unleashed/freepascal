#!/bin/sh
# Full rebuild of the in-tree FPC Unleashed toolchain:
#   1. compiler (3-stage cycle, seeded by the system FPC)
#   2. RTL
#   3. packages
#   4. LCL (lclbase.lpk + lcl.lpk), if a sibling ../lazarus checkout exists
# Usage: ./rebuildu.sh [--clean-packages]
#   --clean-packages  run "make -C packages clean" first; needed after a
#                     CurrentPPULongVersion bump, otherwise up-to-date-looking
#                     units are skipped ("PPU Invalid Long Version" errors).
# Environment:
#   SEED=/path/to/ppcXXX  override the auto-detected seed compiler
set -e
FP="$(cd "$(dirname "$0")" && pwd)"

# Native compiler binary name and unit directory per host CPU.
case "$(uname -m)" in
  x86_64)        PPC=ppcx64;  CPU=x86_64  ;;
  aarch64|arm64) PPC=ppca64;  CPU=aarch64 ;;
  i?86)          PPC=ppc386;  CPU=i386    ;;
  armv7l|armv6l) PPC=ppcarm;  CPU=arm     ;;
  ppc64le)       PPC=ppcppc64; CPU=powerpc64 ;;
  riscv64)       PPC=ppcrv64; CPU=riscv64 ;;
  *) echo "rebuildu.sh: unsupported host cpu $(uname -m) (set SEED= and edit the case)" >&2
     exit 2 ;;
esac
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
UNITDIR="$CPU-$OS"

# Seed compiler: $SEED if given, else whatever binary the system fpc
# driver would run (fpc -PB prints its full path).
if [ -z "$SEED" ]; then
  if command -v fpc >/dev/null 2>&1; then
    SEED="$(fpc -PB 2>/dev/null || true)"
  fi
fi
if [ -z "$SEED" ] || [ ! -x "$SEED" ]; then
  echo "rebuildu.sh: no seed compiler found (no usable 'fpc' on PATH; set SEED=/path/to/$PPC)" >&2
  exit 2
fi
case "$SEED" in
  "$FP"/*) echo "rebuildu.sh: SEED points inside this tree; 'make clean cycle' would delete it mid-run - use an external compiler" >&2
           exit 2 ;;
esac

echo "=== 1/4 compiler (seed: $SEED, target: $UNITDIR) ==="
make -C "$FP/compiler" clean cycle FPC="$SEED"

echo "=== 2/4 rtl ==="
make -C "$FP/rtl" clean all FPC="$FP/compiler/$PPC"

if [ "$1" = "--clean-packages" ]; then
  echo "=== packages clean ==="
  make -C "$FP/packages" clean FPC="$FP/compiler/$PPC"
fi

echo "=== 3/4 packages ==="
make -C "$FP" packages FPC="$FP/compiler/$PPC"

# Rebuild the LCL with the freshly built in-tree compiler.
LAZ="${LAZDIR:-$FP/../lazarus}"
if [ -d "$LAZ" ]; then
  if command -v lazbuild >/dev/null 2>&1; then
    echo "=== 4/4 LCL ($LAZ) ==="
    "$FP/lazbuildu.sh" "$LAZ/lcl/lclbase.lpk"
    "$FP/lazbuildu.sh" "$LAZ/lcl/interfaces/lcl.lpk"
  else
    echo "warning: $LAZ exists but no lazbuild on PATH - skipping LCL" >&2
  fi
else
  echo "=== 4/4 LCL skipped (no $LAZ) ==="
fi

# Stale package PPUs copied into rtl/units shadow the package copies and
# break later builds (e.g. "Can't find unit system.timespan"); RTL make
# clean does not remove them, so warn if any are present.
for u in dateutils strutils system.timespan; do
  if [ -f "$FP/rtl/units/$UNITDIR/$u.ppu" ]; then
    echo "warning: stray $u.ppu in rtl/units/$UNITDIR/ - delete it if unit errors appear" >&2
  fi
done

echo "=== done ==="
