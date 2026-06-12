program type_intrinsic_var_basic_01;

{$mode unleashed}

var
  x: Integer;
  y: Type(x);
begin
  x := 42;
  y := x;
  if y <> 42 then Halt(1);
  if SizeOf(y) <> SizeOf(Integer) then Halt(2);
end.
