program match_inside_try_finally_01;

{$mode unleashed}

var
  trace: String = '';

procedure DoWork(n: Integer);
begin
  try
    match n of
      1: trace := trace + 'B1;';
      2: begin trace := trace + 'B2;'; Exit; end;
      _: trace := trace + 'BX;';
    end;
    trace := trace + 'after-match;';
  finally
    trace := trace + 'F;';
  end;
end;

begin
  DoWork(1);
  if trace <> 'B1;after-match;F;' then halt(1);

  trace := '';
  DoWork(2);
  // Exit must still run the finally
  if trace <> 'B2;F;' then halt(2);

  trace := '';
  DoWork(99);
  if trace <> 'BX;after-match;F;' then halt(3);
end.
