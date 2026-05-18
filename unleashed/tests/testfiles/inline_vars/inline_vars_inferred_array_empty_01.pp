program inline_vars_inferred_array_empty_01;
{$mode unleashed}

// empty `[]` -> array of AnsiString (diagnostic hint emitted);
// the array is a valid 0-length container, indexable after SetLength

begin
  var a := [];
  if Length(a) <> 0 then halt(1);
  if SizeOf(a[0]) <> SizeOf(AnsiString) then halt(2);
  SetLength(a, 2);
  a[0] := 'first';
  a[1] := 'second';
  if a[0] <> 'first' then halt(3);
  if a[1] <> 'second' then halt(4);
end.
