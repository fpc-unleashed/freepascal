program inline_vars_managed_fresh_in_loop_01;

{$mode unleashed}

// a managed inline var declared without initializer in a loop body is
// re-initialized at the declaration point on every pass - values must
// not leak from the previous iteration
procedure check_in_proc;
begin
  for var round := 1 to 3 do
  begin
    var acc: array of integer;
    acc := acc + [round];
    if Length(acc) <> 1 then halt(1);
    if acc[0] <> round then halt(2);
  end;
end;

begin
  // main program body (static storage path)
  for var round := 1 to 3 do
  begin
    var acc: array of integer;
    acc := acc + [round];
    if Length(acc) <> 1 then halt(3);
  end;

  for var round := 1 to 3 do
  begin
    var s: string;
    s := s + 'x';
    if Length(s) <> 1 then halt(4);
  end;

  check_in_proc;

  // unmanaged vars with initializer still assign each pass
  for var round := 1 to 3 do
  begin
    var v := round * 10;
    if v <> round * 10 then halt(5);
  end;
end.
