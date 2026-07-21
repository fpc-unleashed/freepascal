program out_var_multiple_params_01;
{$mode unleashed}

procedure three(a: integer; out b: integer; out c: integer);
begin
  b := a * 2;
  c := a * 3;
end;

begin
  // mix a value arg, an out-var and a discard
  three(5, var bb, _);
  if bb <> 10 then Halt(1);

  three(5, _, var cc);
  if cc <> 15 then Halt(2);
end.
