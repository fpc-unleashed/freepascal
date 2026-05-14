program tuple_param_destructure_01;

{$mode unleashed}

procedure Sum((a, b): (Integer, Integer); var total: Integer);
begin
  total := a + b;
end;

var
  s: Integer;

begin
  Sum((10, 20), s);
  if s <> 30 then halt(1);
end.
