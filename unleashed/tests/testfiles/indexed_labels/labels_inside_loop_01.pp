program labels_inside_loop_01;

{$mode unleashed}

var
  trace: String = '';

procedure Run(targets: array of Integer);
label
  state[0..2];
begin
  for var t in targets do
  begin
    goto state[t];
    state[0]: trace := trace + 'a;'; continue;
    state[1]: trace := trace + 'b;'; continue;
    state[2]: trace := trace + 'c;'; continue;
  end;
end;

begin
  Run([0, 2, 1, 2, 0]);
  if trace <> 'a;c;b;c;a;' then halt(1);
end.
