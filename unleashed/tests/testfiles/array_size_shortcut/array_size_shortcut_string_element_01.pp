program array_size_shortcut_string_element_01;

{$mode unleashed}

// managed element type - strings get refcount-managed individually
var
  s: array[5] of String;
  i: Integer;
begin
  for i := 0 to 4 do
    s[i] := 'item-' + Chr(Ord('0') + i);
  if s[0] <> 'item-0' then halt(1);
  if s[4] <> 'item-4' then halt(2);
  if Length(s[2]) <> 6 then halt(3);

  // mutating one entry must not affect siblings
  s[1] := 'changed';
  if s[0] <> 'item-0' then halt(4);
  if s[1] <> 'changed' then halt(5);
  if s[2] <> 'item-2' then halt(6);
end.
