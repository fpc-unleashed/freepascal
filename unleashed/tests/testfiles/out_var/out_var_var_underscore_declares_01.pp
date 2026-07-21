program out_var_var_underscore_declares_01;
{$mode unleashed}

procedure getval(out x: integer);
begin
  x := 9;
end;

begin
  // `var _` is a regular out-var declaration, not a discard: it declares
  // a variable named `_` that stays readable after the call
  getval(var _);
  if _ <> 9 then Halt(1);
end.
