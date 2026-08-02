program inline_forced_open_array_byvalue_write_fallback_01;
{$mode unleashed}

// writes to a by-value open array would escape the value-copy semantics if
// the parameter were inlined as a reference to the caller's data; the
// fallback call keeps the copy semantics intact

procedure t(a: array of integer); inline;
begin
  a[0] := 5;
  if a[0] <> 5 then Halt(1);
end;

var
  arr: array[0..2] of integer = (1, 2, 3);
begin
  t(arr);
  // the caller's array must stay untouched
  if arr[0] <> 1 then Halt(2);
end.
