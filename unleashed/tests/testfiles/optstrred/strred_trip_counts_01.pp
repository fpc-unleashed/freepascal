{ %OPT="-O4" }
{ Boundary trip counts for an index-multiply reduction: hi = -1 (0 iterations),
  0 (1 iteration) and up to many. The upper bound is a runtime value so the
  reduction runs with a non-constant loop count and its preheader init must be
  harmless on the zero-trip case. }
program strred_trip_counts_01;
var
  g: array[0..1000] of longint;
  i, hi: longint;
begin
  for hi := -1 to 40 do
    begin
      for i := 0 to 1000 do g[i] := -1;
      for i := 0 to hi do g[i*5] := i + 100;
      for i := 0 to hi do if g[i*5] <> i + 100 then Halt(1);
    end;
end.
