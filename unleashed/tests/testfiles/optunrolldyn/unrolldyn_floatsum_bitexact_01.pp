{ %OPT="-O3 -OoUNROLLDYN -OoPREFETCH" }
{ A single-precision reduction  s := s + a[i]  unrolled by -OoUNROLLDYN stays a
  single SERIAL accumulator (four (body; inc) copies, no reassociation), so it
  must be BIT-IDENTICAL to the scalar loop -- unlike the partial-sum reduction
  the vectorizer / -OoREASSOC perform under fast-math. This test prints the raw
  32-bit pattern of the accumulated sum over an array that includes -0.0, +Inf
  and a NaN; the accompanying unrolldyn_check.sh recompiles the SAME source with
  the switches OFF and asserts the printed lines are identical, proving the
  transform changed nothing observable. The in-file Halt checks cover the
  finite-only accumulation against a scalar recompute done here. }
program unrolldyn_floatsum_bitexact_01;
{$mode objfpc}{$H+}

uses
  Math;

type
  TA = array of single;

function reduce(a: TA; n: integer): single;
var i: integer; s: single;
begin
  s := 0;
  for i := 0 to n-1 do
    s := s + a[i];
  reduce := s;
end;

var
  a: TA;
  n, i: integer;
  s, ref, zero, negzero: single;
  bits: longword absolute s;
  refbits: longword absolute ref;
begin
  { do not trap on the Inf/NaN the special-value pass deliberately produces }
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
  n := 4096;
  SetLength(a, n);
  { a deterministic mix whose serial single-precision sum has real rounding }
  for i := 0 to n-1 do
    a[i] := (i mod 7) * 0.1 - 0.3 + i * 1.0e-4;

  s := reduce(a, n);
  ref := 0;
  for i := 0 to n-1 do
    ref := ref + a[i];
  if bits <> refbits then
    Halt(1);   { unrolled serial sum must equal the plain serial sum bit-for-bit }

  WriteLn('finite=', HexStr(bits, 8));

  { now include special values: -0.0 then +Inf then a NaN in the tail. The sum
    becomes NaN once Inf/NaN enter; we only assert it does not crash and prints
    a stable pattern the on/off diff can compare. Inf/NaN are built from runtime
    variables so no compile-time division-by-zero is folded. }
  zero := 0;
  negzero := -zero;
  a[10] := negzero;       { -0.0 }
  a[n-2] := 1.0 / zero;   { +Inf }
  a[n-1] := zero / zero;  { NaN }
  s := reduce(a, n);
  WriteLn('special=', HexStr(bits, 8));
end.
