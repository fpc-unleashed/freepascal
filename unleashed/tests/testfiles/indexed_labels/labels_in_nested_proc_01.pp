program labels_in_nested_proc_01;

{$mode unleashed}

var
  trace: String = '';

procedure Outer;

  procedure Inner(n: Integer);
  label
    state[0..2];
  begin
    goto state[n];
    state[0]: trace := trace + 'a;'; Exit;
    state[1]: trace := trace + 'b;'; Exit;
    state[2]: trace := trace + 'c;';
  end;

begin
  Inner(0);
  Inner(2);
  Inner(1);
end;

begin
  Outer;
  if trace <> 'a;c;b;' then halt(1);
end.
