program out_var_var_param_loop_rezero_01;
{$mode unleashed}

// the zero/seed initialization runs per call, not once per scope:
// inside a loop every iteration starts from a fresh value
procedure bump(var counter: integer);
begin
  inc(counter);
end;

procedure appendStr(var s: string; const part: string);
begin
  s := s + part;
end;

begin
  for var i := 1 to 3 do begin
    bump(var c);
    if c <> 1 then Halt(1);
  end;

  for var i := 1 to 3 do begin
    appendStr(var ms, 'x');
    if ms <> 'x' then Halt(2);
  end;

  for var i := 1 to 3 do begin
    bump(var sc := 10);
    if sc <> 11 then Halt(3);
  end;
end.
