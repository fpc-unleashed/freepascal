{$mode unleashed}
{ test parameter destructuring }
program tuple_param_destructure_02;

procedure ShowXY((x, y): (Integer, Integer));
begin
  if (x <> 10) or (y <> 20) then halt(1);
end;

function Sum((a, b, c): (Integer, Integer, Integer)): Integer;
begin
  Result := a + b + c;
end;

procedure Mixed((n, s): (Integer, String));
begin
  if (n <> 42) or (s <> 'hi') then halt(3);
end;

begin
  ShowXY((10, 20));
  if Sum((1, 2, 3)) <> 6 then halt(2);
  Mixed((42, 'hi'));
  writeln('ok');
end.
