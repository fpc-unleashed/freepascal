program out_var_underscore_shadow_01;
{$mode unleashed}

procedure getval(out x: integer);
begin
  x := 5;
end;

procedure takeval(x: integer);
begin
  if x <> 5 then Halt(2);
end;

var
  _: integer;
begin
  // a declared `_` is a normal variable everywhere, never a discard:
  // the out call writes into it and any parameter kind accepts it
  _ := 0;
  getval(_);
  if _ <> 5 then Halt(1);
  takeval(_);
  writeln(_);
end.
