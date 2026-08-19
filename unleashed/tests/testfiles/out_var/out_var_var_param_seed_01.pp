program out_var_var_param_seed_01;
{$mode unleashed}

// `var x := e` seeds the variable with an explicit value before the call
procedure addTo(var acc: integer; n: integer);
begin
  acc := acc + n;
end;

begin
  addTo(var total := 100, 5);
  if total <> 105 then Halt(1);
end.
