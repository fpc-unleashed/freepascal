program match_proc_calls_01;

{$mode unleashed}

var
  trace: String = '';

procedure A; begin trace := trace + 'A;'; end;
procedure B; begin trace := trace + 'B;'; end;
procedure C; begin trace := trace + 'C;'; end;

procedure Dispatch(n: Integer);
begin
  match n of
    1: A;
    2: B;
    3: C;
    _: ;
  end;
end;

begin
  Dispatch(1); Dispatch(3); Dispatch(99); Dispatch(2);
  if trace <> 'A;C;B;' then halt(1);
end.
