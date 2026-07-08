{ %OPT="-O4" }
{ Backward (downto) loop: the reduction must use the lnf_backward decrement
  path for an index multiply g[i*7]. Bit-identical to a naive recompute. }
program strred_backward_mul_01;
var
  g, ref: array[0..1000] of longint;
  i: longint;
begin
  for i := 0 to 1000 do begin g[i] := 0; ref[i] := 0; end;
  for i := 100 downto 0 do g[i*7]   := i - 50;
  for i := 100 downto 0 do ref[i*7] := i - 50;
  for i := 0 to 1000 do if g[i] <> ref[i] then Halt(1);
end.
