program out_var_typed_decl_seed_01;
{$mode unleashed}

// annotation and seed combine: `var x: T := e`
procedure addTo(var acc: integer; n: integer);
begin
  acc := acc + n;
end;

begin
  addTo(var x: integer := 100, 5);
  if x <> 105 then Halt(1);
end.
