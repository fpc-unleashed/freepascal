program out_var_record_param_01;
{$mode unleashed}

type
  TPoint = record
    x, y: integer;
  end;

procedure makePoint(out p: TPoint);
begin
  p.x := 3;
  p.y := 4;
end;

begin
  // out-var of a record type
  makePoint(var pt);
  if pt.x <> 3 then Halt(1);
  if pt.y <> 4 then Halt(2);
  // discard a record out
  makePoint(_);
end.
