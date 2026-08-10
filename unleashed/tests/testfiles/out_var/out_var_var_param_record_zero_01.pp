program out_var_var_param_record_zero_01;
{$mode unleashed}

// record at a var parameter is zero-filled before the call
type
  TPt = record x, y: integer; end;

procedure movePt(var p: TPt);
begin
  if (p.x <> 0) or (p.y <> 0) then Halt(1);
  inc(p.x); inc(p.y);
end;

begin
  movePt(var p);
  if (p.x <> 1) or (p.y <> 1) then Halt(2);
end.
