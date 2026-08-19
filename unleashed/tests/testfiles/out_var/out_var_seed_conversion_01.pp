program out_var_seed_conversion_01;
{$mode unleashed}

// the variable's type comes from the parameter, not from the seed:
// an integer literal seed converts to the double parameter type
procedure addTo(var acc: double; n: double);
begin
  acc := acc + n;
end;

begin
  addTo(var d := 1, 0.5);
  if abs(d - 1.5) > 1e-9 then Halt(1);
end.
