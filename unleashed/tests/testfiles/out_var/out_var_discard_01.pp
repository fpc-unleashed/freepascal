program out_var_discard_01;
{$mode unleashed}

var
  calls: integer = 0;

procedure getval(out x: integer);
begin
  calls := calls + 1;
  x := 5;
end;

begin
  // `_` discards the out value, but the call still happens
  getval(_);
  if calls <> 1 then Halt(1);
end.
