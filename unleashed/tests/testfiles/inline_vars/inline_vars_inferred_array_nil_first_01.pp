program inline_vars_inferred_array_nil_first_01;
{$mode unleashed}

// nil as first element -> array of Pointer regardless of what follows;
// tail values must be pointer-assignable (classes, procvars, pointers)

type
  TFoo = class end;

begin
  var a := [nil, TFoo.Create, nil, TFoo.Create];
  if Length(a) <> 4 then halt(1);
  if SizeOf(a[0]) <> SizeOf(Pointer) then halt(2);
  if a[0] <> nil then halt(3);
  if a[1] = nil then halt(4);
  if a[2] <> nil then halt(5);
  if a[3] = nil then halt(6);
  TFoo(a[1]).Free;
  TFoo(a[3]).Free;
end.
