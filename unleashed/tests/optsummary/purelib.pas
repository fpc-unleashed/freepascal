unit purelib;

{ Auxiliary unit for the cross-unit -OoPURE / shared-PPU-summary test
  (unleashed/tests/optsummary_check.sh). CALC is provably "const": its result
  depends only on its by-value parameter, it reads/writes no global state and
  cannot raise or trap. Compiled WITH -OoPURE this verdict is serialized into
  purelib.ppu so a caller in another unit can common two identical calls under
  -OoGVNPRE. Compiled WITHOUT -OoPURE the summary is absent and callers must
  fall back to treating CALC as impure. These fixtures are driven from a shell
  check script (not the file-at-a-time suite runner, which has no notion of an
  auxiliary unit), so they live outside testfiles/. }

{$mode objfpc}

interface

function calc(x: longint): longint;

implementation

function calc(x: longint): longint;
begin
  calc := x * x + 3 * x + 7;
end;

end.
