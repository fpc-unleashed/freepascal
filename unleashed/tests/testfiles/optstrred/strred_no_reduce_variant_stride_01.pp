{ %OPT="-O4" }
{ Deliberately NON-matching case: the multiplier s is written inside the loop
  body, so i*s is not loopvar*invariant and must NOT be reduced. Compilation
  must fall back to a per-iteration multiply and the result must be correct. }
program strred_no_reduce_variant_stride_01;
var
  g, ref: array[0..5000] of longint;
  i, s: longint;
begin
  for i := 0 to 5000 do begin g[i] := 0; ref[i] := 0; end;
  s := 1;
  for i := 0 to 60 do begin g[i*s]   := i; s := s + 1; end;
  s := 1;
  for i := 0 to 60 do begin ref[i*s] := i; s := s + 1; end;
  for i := 0 to 5000 do if g[i] <> ref[i] then Halt(1);
end.
