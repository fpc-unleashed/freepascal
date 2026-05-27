program array_size_shortcut_int64_element_01;

{$mode unleashed}

// element size larger than register width still slots correctly
var
  big: array[4] of Int64;
  i: Integer;
  total: Int64;
begin
  big[0] := High(Int64);
  big[1] := Low(Int64);
  big[2] := Int64($DEADBEEFCAFEBABE);
  big[3] := -1;

  if big[0] <> High(Int64) then halt(1);
  if big[1] <> Low(Int64) then halt(2);
  if big[2] <> Int64($DEADBEEFCAFEBABE) then halt(3);
  if big[3] <> -1 then halt(4);

  total := 0;
  for i := 0 to 3 do
    total := total + (big[i] shr 32);
  // just a runtime read across all slots; value is incidental
  if total = 0 then halt(5);
end.
