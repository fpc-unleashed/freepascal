program out_var_seed_picks_var_overload_01;
{$mode unleashed}

// a seeded declaration matches only var parameters, so it selects
// the var overload where a bare `var x` would be ambiguous
procedure pick(out x: integer); overload;
begin
  x := 1;
end;

procedure pick(var x: string); overload;
begin
  x := x + '!';
end;

begin
  pick(var msg := 'hi');
  if msg <> 'hi!' then Halt(1);
end.
