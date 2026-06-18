program out_var_managed_discard_loop_01;
{$mode unleashed}

procedure getstr(out s: string);
begin
  s := 'temp value';
end;

var
  i: integer;
begin
  // discarding a managed out repeatedly: the hidden local must be
  // initialised and finalised each time, no leak or crash
  for i := 1 to 1000 do
    getstr(_);
end.
