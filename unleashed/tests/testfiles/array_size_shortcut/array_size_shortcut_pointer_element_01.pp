program array_size_shortcut_pointer_element_01;

{$mode unleashed}

// untyped pointer slots, plus typed PInteger
var
  raw:  array[3] of Pointer;
  pi:   array[3] of PInteger;
  vals: array[3] of Integer;
  i: Integer;
begin
  vals[0] := 11;
  vals[1] := 22;
  vals[2] := 33;
  for i := 0 to 2 do
    begin
      raw[i] := @vals[i];
      pi[i] := @vals[i];
    end;
  if PInteger(raw[0])^ <> 11 then halt(1);
  if pi[2]^ <> 33 then halt(2);

  pi[1]^ := 99;
  if vals[1] <> 99 then halt(3);
  if PInteger(raw[1])^ <> 99 then halt(4);
end.
