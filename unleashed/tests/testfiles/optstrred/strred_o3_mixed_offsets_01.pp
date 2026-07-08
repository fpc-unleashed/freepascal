{ %OPT="-O3" }
{ Semantics-heavy shape at -O3: pointer-offset writes and reads with several
  distinct invariant strides in the same loop, plus an accumulator. Verifies
  the extension keeps mixed in-index multiplies bit-exact vs a naive recompute. }
program strred_o3_mixed_offsets_01;
var
  a, b, ref_a, ref_b: array[0..4000] of longint;
  i, sa, sb, acc, refacc: longint;
begin
  sa := ParamCount + 3;   { 3 at run time }
  sb := ParamCount + 5;   { 5 at run time }
  for i := 0 to 4000 do begin a[i] := 0; b[i] := 0; ref_a[i] := 0; ref_b[i] := 0; end;
  acc := 0;
  for i := 0 to 200 do
    begin
      a[i*sa] := i;
      b[i*sb] := a[i*sa] + i*11;
      acc := acc + a[i*sa] - b[i*sb];
    end;
  refacc := 0;
  for i := 0 to 200 do
    begin
      ref_a[i*sa] := i;
      ref_b[i*sb] := ref_a[i*sa] + i*11;
      refacc := refacc + ref_a[i*sa] - ref_b[i*sb];
    end;
  for i := 0 to 4000 do if a[i] <> ref_a[i] then Halt(1);
  for i := 0 to 4000 do if b[i] <> ref_b[i] then Halt(2);
  if acc <> refacc then Halt(3);
end.
