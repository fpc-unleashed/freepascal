program out_var_scope_persists_01;
{$mode unleashed}

procedure getval(out x: integer);
begin
  x := 77;
end;

begin
  getval(var v);
  // the out-var stays in scope and is usable after the call
  if v <> 77 then Halt(1);
  v := v + 1;
  if v <> 78 then Halt(2);
end.
