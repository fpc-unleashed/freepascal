program out_var_typed_decl_out_param_01;
{$mode unleashed}

// annotation works at a typed out parameter too - plain capture
procedure getVal(out x: integer);
begin
  x := 42;
end;

begin
  getVal(var n: integer);
  if n <> 42 then Halt(1);
end.
