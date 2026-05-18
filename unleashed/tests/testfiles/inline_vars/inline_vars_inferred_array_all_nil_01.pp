program inline_vars_inferred_array_all_nil_01;
{$mode unleashed}

// every element is nil -> array of Pointer (diagnostic hint emitted at
// compile time, runtime stays usable as a 3-slot pointer container)

begin
  var a := [nil, nil, nil];
  if Length(a) <> 3 then halt(1);
  if SizeOf(a[0]) <> SizeOf(Pointer) then halt(2);
  if a[0] <> nil then halt(3);
  if a[1] <> nil then halt(4);
  if a[2] <> nil then halt(5);
end.
