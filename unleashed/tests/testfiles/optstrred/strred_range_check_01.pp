{ %OPT="-O3 -Cr" }
{ With range checking on, an index-multiply that may trap is deliberately NOT
  reduced (the reduction is gated off under -Cr/-Co), so the per-iteration
  range check remains. All accesses here are in range and must stay correct. }
program strred_range_check_01;
var
  g, ref: array[0..1000] of longint;
  i: longint;
begin
  for i := 0 to 1000 do begin g[i] := 0; ref[i] := 0; end;
  for i := 0 to 100 do g[i*7]   := i + 1;
  for i := 0 to 100 do ref[i*7] := i + 1;
  for i := 0 to 1000 do if g[i] <> ref[i] then Halt(1);
end.
