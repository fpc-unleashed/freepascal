program inline_vars_inferred_array_bool_01;
{$mode unleashed}

// boolean literals -> array of Boolean (1 byte per element)

begin
  var a := [true, false, true, false, true];
  if Length(a) <> 5 then halt(1);
  if SizeOf(a[0]) <> SizeOf(Boolean) then halt(2);
  if a[0] <> true then halt(3);
  if a[1] <> false then halt(4);
  if a[2] <> true then halt(5);
  if a[3] <> false then halt(6);
  if a[4] <> true then halt(7);
end.
