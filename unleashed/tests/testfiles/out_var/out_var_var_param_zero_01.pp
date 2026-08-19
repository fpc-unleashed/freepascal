program out_var_var_param_zero_01;
{$mode unleashed}

// `var x` at a var parameter zero-initializes the fresh variable
// before the call, so the callee reads a defined value
procedure addTo(var acc: integer; n: integer);
begin
  if acc <> 0 then Halt(1);
  acc := acc + n;
end;

begin
  addTo(var total, 5);
  if total <> 5 then Halt(2);
end.
