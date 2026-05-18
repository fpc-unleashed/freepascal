program inline_vars_inferred_array_string_no_truncation_01;
{$mode unleashed}

// regression: the legacy carrier sized the static array to the first
// element's exact byte width and silently truncated everything longer.
// the inferred dynamic array of String must keep each element fully.

begin
  var a := ['', 'a', 'bb', 'much longer than first element'];
  if Length(a) <> 4 then halt(1);
  if a[0] <> '' then halt(2);
  if a[1] <> 'a' then halt(3);
  if a[2] <> 'bb' then halt(4);
  if a[3] <> 'much longer than first element' then halt(5);
  if Length(a[3]) <> 30 then halt(6);
  if SizeOf(a[0]) <> SizeOf(AnsiString) then halt(7);
end.
