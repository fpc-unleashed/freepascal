program out_var_capture_basic_01;
{$mode unleashed}

procedure compute(a, b: integer; out sum: integer);
begin
  sum := a + b;
end;

begin
  compute(3, 4, var s);
  if s <> 7 then Halt(1);
end.
