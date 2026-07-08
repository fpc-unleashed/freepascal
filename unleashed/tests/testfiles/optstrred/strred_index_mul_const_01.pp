{ %OPT="-O4" }
{ Induction-variable strength reduction of a multiply embedded in an array
  index: g[i*7] as both a write target and a read source. At -O3+ the per-
  iteration imul is turned into an additive pointer/index accumulator; the
  results must stay bit-identical to a naive recompute. }
program strred_index_mul_const_01;
var
  g, ref: array[0..1000] of longint;
  i, acc, accref: longint;
begin
  for i := 0 to 1000 do begin g[i] := 0; ref[i] := 0; end;
  { write through g[i*7] }
  for i := 0 to 100 do g[i*7] := i*7 + 3;
  for i := 0 to 100 do ref[i*7] := i*7 + 3;
  for i := 0 to 1000 do if g[i] <> ref[i] then Halt(1);
  { read through g[i*7] }
  acc := 0;    for i := 0 to 100 do acc := acc + g[i*7];
  accref := 0; for i := 0 to 100 do accref := accref + ref[i*7];
  if acc <> accref then Halt(2);
end.
