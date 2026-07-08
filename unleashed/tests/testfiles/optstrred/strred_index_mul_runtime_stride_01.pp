{ %OPT="-O4" }
{ p[i*stride] where the stride is only known at runtime (derived from ParamCount
  so the optimizer cannot fold it). loopvar*invariant inside the index is
  reduced to a strided accumulator; must match a naive recompute. }
program strred_index_mul_runtime_stride_01;
var
  p, ref: array[0..2000] of longint;
  i, stride: longint;
begin
  stride := ParamCount + 5;   { 5 at run time, opaque to the compiler }
  for i := 0 to 2000 do begin p[i] := 0; ref[i] := 0; end;
  for i := 0 to 300 do p[i*stride]   := 1000 - i;
  for i := 0 to 300 do ref[i*stride] := 1000 - i;
  for i := 0 to 2000 do if p[i] <> ref[i] then Halt(1);
end.
