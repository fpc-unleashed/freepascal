{ %OPT="-O4" }
{ Multi-term flat offset p[ch*size + row*width + col] in a nested loop -- the
  neural-api conv/dense inner-loop address pattern. Each loop level's
  counter*invariant multiply (ch*size, row*width) is strength-reduced; the
  innermost +col add stays. Result must be bit-identical to a naive recompute. }
program strred_flat_offset_nested_01;
var
  p, ref: array[0..20000] of longint;
  ch, row, col, size, width, idx, errors: longint;
begin
  width := 13; size := width*7;      { 7 rows x 13 cols per channel }
  for idx := 0 to 20000 do begin p[idx] := 0; ref[idx] := 0; end;
  for ch := 0 to 19 do
    for row := 0 to 6 do
      for col := 0 to 12 do
        p[ch*size + row*width + col] := ch*1000 + row*100 + col;
  for ch := 0 to 19 do
    for row := 0 to 6 do
      for col := 0 to 12 do
        begin
          idx := ch*size + row*width + col;
          ref[idx] := ch*1000 + row*100 + col;
        end;
  errors := 0;
  for idx := 0 to 20000 do if p[idx] <> ref[idx] then inc(errors);
  if errors <> 0 then Halt(1);
end.
