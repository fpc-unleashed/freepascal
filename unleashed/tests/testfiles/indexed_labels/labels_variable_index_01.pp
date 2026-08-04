program labels_variable_index_01;

{$mode unleashed}

label
  state[0..2];

var
  result_v: Integer = 0;

procedure Run(n: Integer);
label
  state[0..2];
begin
  goto state[n];

  state[0]: result_v := 10; Exit;
  state[1]: result_v := 20; Exit;
  state[2]: result_v := 30; Exit;
end;

begin
  Run(0);
  if result_v <> 10 then halt(1);
  Run(1);
  if result_v <> 20 then halt(2);
  Run(2);
  if result_v <> 30 then halt(3);
end.
