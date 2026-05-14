program try_finally_inside_match_branch_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

procedure DoWork(n: Integer);
begin
  match n of
    1:
      try
        trace := trace + 'try1;';
        raise Exception.Create('e1');
      except
        on E: Exception do
          trace := trace + 'caught1;';
      end;
    2:
      try
        trace := trace + 'try2;';
      finally
        trace := trace + 'finally2;';
      end;
    _: trace := trace + 'else;';
  end;
end;

begin
  DoWork(1);
  if trace <> 'try1;caught1;' then halt(1);

  trace := '';
  DoWork(2);
  if trace <> 'try2;finally2;' then halt(2);

  trace := '';
  DoWork(99);
  if trace <> 'else;' then halt(3);
end.
