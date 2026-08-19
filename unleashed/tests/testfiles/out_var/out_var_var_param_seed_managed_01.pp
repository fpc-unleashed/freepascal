program out_var_var_param_seed_managed_01;
{$mode unleashed}

// managed type at a var parameter: zeroed to '' without a seed,
// seeded value visible to the callee otherwise
procedure appendStr(var s: string; const part: string);
begin
  s := s + part;
end;

begin
  appendStr(var plain, 'abc');
  if plain <> 'abc' then Halt(1);

  appendStr(var seeded := 'xy', 'z');
  if seeded <> 'xyz' then Halt(2);
end.
