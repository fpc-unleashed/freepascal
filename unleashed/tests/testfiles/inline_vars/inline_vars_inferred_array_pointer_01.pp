program inline_vars_inferred_array_pointer_01;
{$mode unleashed}

// first element is an explicit Pointer var -> array of Pointer;
// subsequent elements that are pointer-compatible (including nil) fit

var
  x, y, z: Integer;
begin
  var a := [@x, @y, @z, nil];
  if Length(a) <> 4 then halt(1);
  if SizeOf(a[0]) <> SizeOf(Pointer) then halt(2);
  if a[0] <> @x then halt(3);
  if a[1] <> @y then halt(4);
  if a[2] <> @z then halt(5);
  if a[3] <> nil then halt(6);
end.
